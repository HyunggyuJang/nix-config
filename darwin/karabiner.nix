{
  text = ''
{
    "global": {
        "ask_for_confirmation_before_quitting": true,
        "check_for_updates_on_startup": false,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false,
        "unsafe_ui": false
    },
    "profiles": [
        {
            "complex_modifications": {
                "parameters": {
                    "basic.simultaneous_threshold_milliseconds": 50,
                    "basic.to_delayed_action_delay_milliseconds": 500,
                    "basic.to_if_alone_timeout_milliseconds": 1000,
                    "basic.to_if_held_down_threshold_milliseconds": 500,
                    "mouse_motion_to_scroll.speed": 100
                },
                "rules": [
                    {
                        "description": "Change tab to fn if pressed with other keys, to tab if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "tab",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "fn"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "tab"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "open_bracket",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "fn"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "open_bracket"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "e",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "open_bracket",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "r",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "close_bracket",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "d",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "9",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "f",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "0",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "c",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "open_bracket"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "v",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "close_bracket"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "s",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "4",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "a",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "6",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "q",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "1",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "z",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "slash",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "t",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "backslash"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "g",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "grave_accent_and_tilde"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "b",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "grave_accent_and_tilde",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "u",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "5",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "i",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "equal_sign"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "k",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "hyphen"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "j",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "8",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "comma",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "hyphen",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "m",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "7",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "h",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "3",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "n",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "backslash",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "l",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "equal_sign",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "semicolon",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "quote"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "quote",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "quote",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "period",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "comma",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "slash",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "period",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change escape to control if pressed with other keys, to escape if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "escape",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_control"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "escape"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change return key to control if pressed with other keys, to return if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "return_or_enter",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_control"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "return_or_enter"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change to English layout if Left ⌘ key pressed alone, else send ⌘ key.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "left_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f17"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "right_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f18"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "right_option",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_option"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f19"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Map F6 (Do Not Disturb) to Cmd+Opt+Eject for Sleep Mac",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "f6"
                                },
                                "to_after_key_up": [
                                    {
                                        "consumer_key_code": "eject",
                                        "modifiers": [
                                            "left_gui",
                                            "left_alt"
                                        ],
                                        "repeat": false
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    }
                ]
            },
            "devices": [
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 33,
                        "vendor_id": 1278
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [
                        {
                            "from": {
                                "key_code": "left_control"
                            },
                            "to": [
                                {
                                    "key_code": "escape"
                                }
                            ]
                        }
                    ],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 569,
                        "vendor_id": 1452
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [
                        {
                            "from": {
                                "key_code": "caps_lock"
                            },
                            "to": [
                                {
                                    "key_code": "escape"
                                }
                            ]
                        },
                        {
                            "from": {
                                "key_code": "escape"
                            },
                            "to": [
                                {
                                    "key_code": "caps_lock"
                                }
                            ]
                        }
                    ],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 641,
                        "vendor_id": 1452
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [
                        {
                            "from": {
                                "key_code": "caps_lock"
                            },
                            "to": [
                                {
                                    "key_code": "escape"
                                }
                            ]
                        },
                        {
                            "from": {
                                "key_code": "escape"
                            },
                            "to": [
                                {
                                    "key_code": "caps_lock"
                                }
                            ]
                        }
                    ],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": true,
                        "product_id": 6505,
                        "vendor_id": 12951
                    },
                    "ignore": true,
                    "manipulate_caps_lock_led": false,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 6505,
                        "vendor_id": 12951
                    },
                    "ignore": true,
                    "manipulate_caps_lock_led": false,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": false,
                        "is_pointing_device": true,
                        "product_id": 641,
                        "vendor_id": 1452
                    },
                    "ignore": true,
                    "manipulate_caps_lock_led": false,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 28705,
                        "vendor_id": 1256
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [
                        {
                            "from": {
                                "key_code": "caps_lock"
                            },
                            "to": [
                                {
                                    "key_code": "escape"
                                }
                            ]
                        },
                        {
                            "from": {
                                "key_code": "escape"
                            },
                            "to": [
                                {
                                    "key_code": "caps_lock"
                                }
                            ]
                        }
                    ],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 834,
                        "vendor_id": 1452
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [
                        {
                            "from": {
                                "key_code": "caps_lock"
                            },
                            "to": [
                                {
                                    "key_code": "escape"
                                }
                            ]
                        },
                        {
                            "from": {
                                "key_code": "escape"
                            },
                            "to": [
                                {
                                    "key_code": "caps_lock"
                                }
                            ]
                        }
                    ],
                    "treat_as_built_in_keyboard": false
                },
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "game_pad_swap_sticks": false,
                    "identifiers": {
                        "is_game_pad": false,
                        "is_keyboard": false,
                        "is_pointing_device": true,
                        "product_id": 834,
                        "vendor_id": 1452
                    },
                    "ignore": true,
                    "manipulate_caps_lock_led": false,
                    "mouse_flip_horizontal_wheel": false,
                    "mouse_flip_vertical_wheel": false,
                    "mouse_flip_x": false,
                    "mouse_flip_y": false,
                    "mouse_swap_wheels": false,
                    "mouse_swap_xy": false,
                    "simple_modifications": [],
                    "treat_as_built_in_keyboard": false
                }
            ],
            "fn_function_keys": [
                {
                    "from": {
                        "key_code": "f1"
                    },
                    "to": [
                        {
                            "consumer_key_code": "display_brightness_decrement"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f2"
                    },
                    "to": [
                        {
                            "consumer_key_code": "display_brightness_increment"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f3"
                    },
                    "to": [
                        {
                            "apple_vendor_keyboard_key_code": "mission_control"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f4"
                    },
                    "to": [
                        {
                            "apple_vendor_keyboard_key_code": "spotlight"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f5"
                    },
                    "to": [
                        {
                            "consumer_key_code": "dictation"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f6"
                    },
                    "to": [
                        {
                            "key_code": "f6"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f7"
                    },
                    "to": [
                        {
                            "consumer_key_code": "rewind"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f8"
                    },
                    "to": [
                        {
                            "consumer_key_code": "play_or_pause"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f9"
                    },
                    "to": [
                        {
                            "consumer_key_code": "fast_forward"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f10"
                    },
                    "to": [
                        {
                            "consumer_key_code": "mute"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f11"
                    },
                    "to": [
                        {
                            "consumer_key_code": "volume_decrement"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f12"
                    },
                    "to": [
                        {
                            "consumer_key_code": "volume_increment"
                        }
                    ]
                }
            ],
            "name": "Default profile",
            "parameters": {
                "delay_milliseconds_before_open_device": 1000
            },
            "selected": true,
            "simple_modifications": [],
            "virtual_hid_keyboard": {
                "country_code": 0,
                "indicate_sticky_modifier_keys_state": true,
                "mouse_key_xy_scale": 100
            }
        }
    ]
}
  '';
}
