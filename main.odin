package odinup

import "core:fmt"
import "core:os"

main :: proc() {
	cmd, args := parse_args()

	// Initialize user path configurations (~/.odinup)
	init_config()

	switch cmd {
	case .Version:
		print_version()
	case .Help:
		print_usage()
	case .ListRemote:
		list_remote(false)
	case .ListRemoteOls:
		list_remote(true)
	case .List:
		list_local(false)
	case .ListOls:
		list_local(true)
	case .Install:
		if len(args) == 0 {
			fmt.eprintf(
				"%s%s ERROR %s %sPlease specify a version to install.%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			os.exit(1)
		}
		if !check_clang_availability() {
			fmt.eprintf(
				"%s%s MISSING %s %sclang not found. Odin requires clang as its backend.%s\n",
				BG_YELLOW,
				BLACK,
				RESET,
				YELLOW,
				RESET,
			)
			os.exit(1)
		}
		install_version(args[0], false)

	case .Use:
		if len(args) == 0 {
			fmt.eprintf(
				"%s%s ERROR %s %sPlease specify a version (e.g. odinup use dev-2026-04)%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			os.exit(1)
		}
		use_version(args[0], false)
	case .InstallOls:
		if len(args) == 0 {
			fmt.eprintf(
				"%s%s ERROR %s %sPlease specify an Ols version.%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			os.exit(1)
		}
		install_version(args[0], true)

	case .UseOls:
		if len(args) == 0 {
			fmt.eprintf(
				"%s%s ERROR %s %sPlease specify an Ols version.%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			os.exit(1)
		}
		use_version(args[0], true)
	case .Env:
		print_env()
	}
}
