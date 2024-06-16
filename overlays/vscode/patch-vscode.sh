# Define variables from arguments
extensionPath="$1"
installationPath="$2"

bootstrapName='bootstrap-amd.js'
modules='vs/modules'
patch='vs/patch'
mainJsName='main.js'
mainProcessJsName='process.main.js'
workbenchHtmlName='workbench.html'
browserMain='browser.main.js'

bootstrapPath="${installationPath}/${bootstrapName}"
mainJsPath="${installationPath}/${mainJsName}"
workbenchHtmldir="${installationPath}/vs/code/electron-sandbox/workbench"
workbenchHtmlPath="${workbenchHtmldir}/${workbenchHtmlName}"
workbenchHtmlReplacementPath="${workbenchHtmlPath/workbench.html/workbench-apc-extension.html}"
patchPath="${installationPath}/${patch}"
modulesPath="${installationPath}/${modules}"
browserEntrypointPath="${patchPath}/${browserMain}"

patchBootstrap() {
  local bootstrapResourcesPath="${extensionPath}/resources/${bootstrapName}"
  local inject='
  if (entrypoint === "vs/code/electron-main/main") {
    const fs = nodeRequire("fs");
    const p = nodeRequire("path");
    const readFile = fs.readFile;
    fs.readFile = function (path, options, callback) {
      if (path.endsWith(p.join("electron-main", "main.js"))) {
        readFile(path, options, function () {
          loader(["vs/patch/main"], console.log, console.log);
          callback.apply(this, arguments);
        });
      } else readFile(...arguments);
    };
  }
  performance.mark("code/fork/willLoadCode");'

  local patchedbootstrapJs
  patchedbootstrapJs=$(sed "/performance.mark('code\/fork\/willLoadCode');/r /dev/stdin" <<< "$inject" < "${bootstrapResourcesPath}")

  echo "$patchedbootstrapJs" > "${bootstrapPath}"
}

patchMain() {
  local proccesMainPath="${extensionPath}/resources/${mainProcessJsName}"
  local processEntrypointPath="${patchPath}/${mainJsName}"
  local processMainSourcePath="${patchPath}/${mainProcessJsName}"

  local moduleName='vs/modules'
  local patchModule='vs/patch'

  local files='["'"${patchModule}/process.main"', '"${moduleName}/patch.main"', '"${moduleName}/utils"']'
  local data='define('"${files}"', () => { });'

  local patchedMainJs
  patchedMainJs=$(sed "s/require_bootstrap_amd()/require(\".\/bootstrap-amd\")/" "${mainJsPath}")

  echo "$patchedMainJs" > "${mainJsPath}"

  mkdir -p "${patchPath}"
  cp "${proccesMainPath}" "${processMainSourcePath}"
  echo "$data" > "${processEntrypointPath}"

  mkdir -p "${modulesPath}"
  cp -r "${extensionPath}/${modules}"/* "${modulesPath}"
}

patchWorkbench() {
  local workbenchHtmldirRelative
  workbenchHtmldirRelative=$(realpath --relative-to="${workbenchHtmldir}" "${patchPath}" | tr '\\' '/')

  local browserEntrypointPathRelative
  browserEntrypointPathRelative=$(realpath --relative-to="${workbenchHtmldir}" "${browserEntrypointPath}" | tr '\\' '/')

  local patchedWorkbenchHtml
  patchedWorkbenchHtml=$(cat <<EOF
<!DOCTYPE html>
<html>
  <head><meta charset="utf-8" /></head>
  <body aria-label=""></body>
  <!-- Startup (do not modify order of script tags!) -->
  <script src="${browserEntrypointPathRelative}"></script>
  <script src="workbench.js"></script>
</html>
EOF
)

  echo "$patchedWorkbenchHtml" > "${workbenchHtmlReplacementPath}"

  local data
  data=$(cat <<'EOF'
'use strict';
function _apcPatch(bootstrapWindow) {
  const _prev = bootstrapWindow.load;
  function bootstrapWindowLoad(modulePaths, resultCallback, options) {
    const prevBeforeLoaderConfig = options.beforeLoaderConfig;
    function beforeLoaderConfig(configuration, loaderConfig) {
      if (!loaderConfig) loaderConfig = configuration;
      if (typeof prevBeforeLoaderConfig === 'function') prevBeforeLoaderConfig(configuration, loaderConfig);
      require.define("apc-patch", {
        load: (name, req, onload, config) => req([name],
        (value) => req(["vs/modules/main"],
        () => onload(value),
        error => (console.error(error), onload(value))))
      });
    };
    options.beforeLoaderConfig = beforeLoaderConfig;

    if ("vs/workbench/workbench.desktop.main" === modulePaths[0]) modulePaths[0] = "apc-patch!" + modulePaths[0];
    return _prev(modulePaths, resultCallback, options);
  };

  bootstrapWindow.load = bootstrapWindowLoad;
}

if (window.MonacoBootstrapWindow) _apcPatch(window.MonacoBootstrapWindow);
else {
  Object.defineProperty(
    window,
    "MonacoBootstrapWindow",
    {
      set: function (value) { _apcPatch(value); window._patchMonacoBootstrapWindow = value; },
      get: function () { return window._patchMonacoBootstrapWindow; }
    }
  );
}
EOF
)
  echo "$data" > "${browserEntrypointPath}"
}

install() {
  patchBootstrap
  patchMain
  patchWorkbench
}

install
echo "Patched VSCode with apc-extension."
