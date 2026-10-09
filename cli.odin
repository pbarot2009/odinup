package odinup

import "core:fmt"
import "core:os"
import "core:terminal/ansi"

// Base Styles (Standard Odin Constants)
RESET :: ansi.CSI + ansi.RESET + ansi.SGR
BOLD :: ansi.CSI + ansi.BOLD + ansi.SGR
ITALIC :: ansi.CSI + ansi.ITALIC + ansi.SGR
UNDERLINE :: ansi.CSI + ansi.UNDERLINE + ansi.SGR

// Foreground
RED :: ansi.CSI + ansi.FG_RED + ansi.SGR
GREEN :: ansi.CSI + ansi.FG_GREEN + ansi.SGR
YELLOW :: ansi.CSI + ansi.FG_YELLOW + ansi.SGR
BLUE :: ansi.CSI + ansi.FG_BLUE + ansi.SGR
MAGENTA :: ansi.CSI + ansi.FG_MAGENTA + ansi.SGR
CYAN :: ansi.CSI + ansi.FG_CYAN + ansi.SGR
BLACK :: ansi.CSI + "30" + ansi.SGR

// Bright Foreground
GRAY :: ansi.CSI + "90" + ansi.SGR
B_RED :: ansi.CSI + "91" + ansi.SGR
B_GREEN :: ansi.CSI + "92" + ansi.SGR
B_YELLOW :: ansi.CSI + "93" + ansi.SGR
B_BLUE :: ansi.CSI + "94" + ansi.SGR
B_MAGENTA :: ansi.CSI + "95" + ansi.SGR
B_CYAN :: ansi.CSI + "96" + ansi.SGR
B_WHITE :: ansi.CSI + "97" + ansi.SGR

// Background Colors (Standard & Bright)
BG_RED :: ansi.CSI + ansi.BG_RED + ansi.SGR
BG_GREEN :: ansi.CSI + ansi.BG_GREEN + ansi.SGR
BG_YELLOW :: ansi.CSI + ansi.BG_YELLOW + ansi.SGR
BG_BLUE :: ansi.CSI + ansi.BG_BLUE + ansi.SGR
BG_CYAN :: ansi.CSI + ansi.BG_CYAN + ansi.SGR
BG_WHITE :: ansi.CSI + "107" + ansi.SGR // Bright White Background

// Practical Combinations
SUCCESS :: BOLD + B_GREEN
ERROR :: BOLD + B_RED
WARN :: BOLD + B_YELLOW
INFO :: BOLD + B_CYAN
DEBUG :: ITALIC + GRAY

Command :: enum {
	Help,
	ListRemote,
	ListRemoteOls,
	List,
	ListOls,
	Install,
	InstallOls,
	Use,
	UseOls,
	Env,
	Version,
}

parse_args :: proc() -> (Command, []string) {
	if len(os.args) < 2 {
		return .Help, nil
	}

	cmd_str := os.args[1]
	args := os.args[2:]

	switch cmd_str {
	case "list", "ls":
		if len(os.args) > 2 {
			if os.args[2] == "-ols" {
				if len(os.args) > 3 {
					// Return the version string after -ols
					return .ListOls, os.args[3:]
				}
				return .ListOls, nil
			} else if os.args[2][0] == '-' {
				fmt.eprintf(
					"%s%s UNKNOWN FLAG: %s %s %sDid you mean -ols?%s\n",
					BG_RED,
					BLACK,
					os.args[2],
					RESET,
					RED,
					RESET,
				)
				os.exit(1)
			}
		}
		return .List, args

	case "list-remote", "lr":
		if len(os.args) > 2 {
			if os.args[2] == "-ols" {
				if len(os.args) > 3 {
					// Return the version string after -ols
					return .ListRemoteOls, os.args[3:]
				}
				return .ListRemoteOls, nil
			} else if os.args[2][0] == '-' {
				fmt.eprintf(
					"%s%s UNKNOWN FLAG: %s %s %sDid you mean -ols?%s\n",
					BG_RED,
					BLACK,
					os.args[2],
					RESET,
					RED,
					RESET,
				)
				os.exit(1)
			}
		}
		return .ListRemote, args

	case "install", "i":
		if len(os.args) > 2 {
			if os.args[2] == "-ols" {
				if len(os.args) > 3 {
					// Return the version string after -ols
					return .InstallOls, os.args[3:]
				}
				return .InstallOls, nil
			} else if os.args[2][0] == '-' {
				fmt.eprintf(
					"%s%s UNKNOWN FLAG: %s %s %sDid you mean -ols?%s\n",
					BG_RED,
					BLACK,
					os.args[2],
					RESET,
					RED,
					RESET,
				)
				os.exit(1)
			}
		}
		return .Install, args

	case "use", "u":
		if len(os.args) > 2 {
			if os.args[2] == "-ols" {
				if len(os.args) > 3 {
					// Return the version string after -ols
					return .UseOls, os.args[3:]
				}
				return .UseOls, nil
			} else if os.args[2][0] == '-' {
				fmt.eprintf(
					"%s%s UNKNOWN FLAG: %s %s %sDid you mean -ols?%s\n",
					BG_RED,
					BLACK,
					os.args[2],
					RESET,
					RED,
					RESET,
				)
				os.exit(1)
			}
		}
		return .Use, args
	case "env":
		return .Env, args
	case "help", "-h", "--help":
		return .Help, args
	case "version", "-v", "--version":
		return .Version, args
	case:
		fmt.eprintf("%s%s✖ Unknown command: %s%s\n\n", B_RED, BOLD, cmd_str, RESET)
		return .Help, args
	}
}

print_usage :: proc() {
	fmt.printf(
		"%s%sodinup%s %s- The robust Odin version manager%s\n\n",
		BOLD,
		B_CYAN,
		RESET,
		GRAY,
		RESET,
	)

	fmt.printf("%sUsage:%s\n", B_YELLOW, RESET)
	fmt.printf("  odinup <command> [args]\n\n")

	fmt.printf("%sCommands:%s\n", B_YELLOW, RESET)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_GREEN,
		"list, ls",
		RESET,
		"List locally installed versions of Odin",
	)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_GREEN,
		"list-remote, lr",
		RESET,
		"List all available versions of Odin from GitHub",
	)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_GREEN,
		"install <version>, i <version>",
		RESET,
		"Download and install a specific version of Odin",
	)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_GREEN,
		"use <version>, u <version>",
		RESET,
		"Set the given version as the active one of Odin",
	)

	fmt.printf("\n%sOls Specific:%s\n", B_YELLOW, RESET)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_CYAN,
		"list -ols, ls -ols",
		RESET,
		"List locally installed versions of Ols",
	)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_CYAN,
		"list-remote -ols, lr -ols",
		RESET,
		"List all available versions of Ols from GitHub",
	)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_CYAN,
		"install -ols <version>, i -ols <version>",
		RESET,
		"Download and install a specific version of Ols",
	)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		B_CYAN,
		"use -ols <version>, u -ols <version>",
		RESET,
		"Set the given version as the active one of Ols",
	)

	fmt.printf("\n%sSystem:%s\n", B_YELLOW, RESET)
	fmt.printf(
		"  %s%-48s%s  %s\n",
		GRAY,
		"env",
		RESET,
		"Print the environment variables to configure your shell",
	)
	fmt.printf("  %s%-48s%s  %s\n", GRAY, "help, -h", RESET, "Show this help message")
	fmt.printf("  %s%-48s%s  %s\n", GRAY, "version, -v", RESET, "Print the version information")
}
