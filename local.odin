package odinup

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

list_local :: proc(ols: bool) {
	if ols {
		f, err := os.open(cfg.ols_dir)
		if err != os.ERROR_NONE {
			fmt.eprintf(
				"%s%s ERROR %s %sFailed to open versions directory%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			return
		}
		defer os.close(f)

		fi, read_err := os.read_dir(f, -1, context.allocator)
		if read_err != os.ERROR_NONE {
			fmt.eprintf(
				"%s%s ERROR %s %sFailed to read versions directory%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			return
		}

		// Determine currently active version
		active_version := ""
		wrapper_name := "ols"
		if ODIN_OS == .Windows do wrapper_name = "ols.bat"

		wrapper_path, _ := filepath.join([]string{cfg.bin_dir, wrapper_name}, context.allocator)
		if wrapper_data, w_err := os.read_entire_file_from_path(wrapper_path, context.allocator);
		   w_err == nil {
			wrapper_content := string(wrapper_data)
			for info in fi {
				if os.is_dir(info.fullpath) && strings.contains(wrapper_content, info.name) {
					active_version = info.name
					break
				}
			}
		}

		fmt.printf("%s📦 Installed versions:%s\n", BOLD, RESET)
		if len(fi) == 0 {
			fmt.println("  (none)")
			return
		}

		for info in fi {
			if info.name == active_version {
				// Background makes it impossible to miss
				fmt.printf(
					"  %s%s ★ %-10s %s%s Active %s\n",
					BG_GREEN,
					BLACK,
					info.name,
					BLACK,
					BG_WHITE,
					RESET,
				)
			} else {
				fmt.printf("    %-10s\n", info.name)
			}
		}
	} else {
		f, err := os.open(cfg.odin_dir)
		if err != os.ERROR_NONE {
			fmt.eprintf(
				"%s%s ERROR %s %sFailed to open versions directory%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			return
		}
		defer os.close(f)

		fi, read_err := os.read_dir(f, -1, context.allocator)
		if read_err != os.ERROR_NONE {
			fmt.eprintf(
				"%s%s ERROR %s %sFailed to read versions directory%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				RESET,
			)
			return
		}

		// Determine currently active version
		active_version := ""
		wrapper_name := "odin"
		if ODIN_OS == .Windows do wrapper_name = "odin.bat"

		wrapper_path, _ := filepath.join([]string{cfg.bin_dir, wrapper_name}, context.allocator)
		if wrapper_data, w_err := os.read_entire_file_from_path(wrapper_path, context.allocator);
		   w_err == nil {
			wrapper_content := string(wrapper_data)
			for info in fi {
				if os.is_dir(info.fullpath) && strings.contains(wrapper_content, info.name) {
					active_version = info.name
					break
				}
			}
		}

		fmt.printf("%s📦 Installed versions:%s\n", BOLD, RESET)
		if len(fi) == 0 {
			fmt.println("  (none)")
			return
		}

		for info in fi {
			if os.is_dir(info.fullpath) {
				if info.name == active_version {
					// Background makes it impossible to miss
					fmt.printf(
						"  %s%s ★ %-10s %s%s Active %s\n",
						BG_GREEN,
						BLACK,
						info.name,
						BLACK,
						BG_WHITE,
						RESET,
					)
				} else {
					fmt.printf("    %-10s\n", info.name)
				}
			}
		}
	}
}

use_version :: proc(version: string, ols: bool) {
	if ols {
		version_path, _ := filepath.join([]string{cfg.ols_dir, version}, context.allocator)
		if !os.exists(version_path) {
			fmt.eprintf(
				"%s%s ERROR %s %sVersion '%s' is not installed.%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				version,
				RESET,
			)
			os.exit(1)
		}

		platform := ols_platform_string()
		exe_name := fmt.tprintf("ols-%s", platform)
		when ODIN_OS == .Windows {
			exe_name = fmt.tprintf("ols-%s.exe", platform)
		}

		target_exe := find_executable(version_path, exe_name)
		if target_exe == "" {
			fmt.eprintf(
				"%s%s ERROR %s %sCould not find Ols executable inside %s%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				version_path,
				RESET,
			)
			os.exit(1)
		}

		create_wrapper_script(target_exe, "ols")

		fmt_exe_name := fmt.tprintf("odinfmt-%s", platform)
		if ODIN_OS == .Windows do fmt_exe_name = fmt.tprintf("%s.exe", fmt_exe_name)

		target_fmt := find_executable(version_path, fmt_exe_name)
		if target_fmt != "" {
			create_wrapper_script(target_fmt, "odinfmt")
			fmt.printf(
				"%s%s✔ Successfully set odinfmt version to: %s%s\n",
				GREEN,
				BOLD,
				version,
				RESET,
			)
		}

		fmt.printf("%s%s✔ Successfully set Ols version to: %s%s\n", GREEN, BOLD, version, RESET)
		fmt.printf(
			"\n%s%s NOTE %s If your terminal still shows the old version, run:\n",
			BG_YELLOW,
			BLACK,
			RESET,
		)
		fmt.printf("  %sexport PATH=\"$HOME/.odinup/bin:$PATH\"%s\n", CYAN, RESET)
	} else {
		version_path, _ := filepath.join([]string{cfg.odin_dir, version}, context.allocator)
		if !os.exists(version_path) {
			fmt.eprintf(
				"%s%s ERROR %s %sVersion '%s' is not installed.%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				version,
				RESET,
			)
			os.exit(1)
		}

		exe_name := "odin"
		when ODIN_OS == .Windows {
			exe_name = "odin.exe"
		}

		target_exe := find_executable(version_path, exe_name)
		if target_exe == "" {
			fmt.eprintf(
				"%s%s ERROR %s %sCould not find Odin executable inside %s%s\n",
				BG_RED,
				BLACK,
				RESET,
				RED,
				version_path,
				RESET,
			)
			os.exit(1)
		}

		create_wrapper_script(target_exe, "odin")

		fmt.printf("%s%s✔ Successfully set Odin version to: %s%s\n", GREEN, BOLD, version, RESET)
		fmt.printf(
			"\n%s%s NOTE %s If your terminal still shows the old version, run:\n",
			BG_YELLOW,
			BLACK,
			RESET,
		)
		fmt.printf("  %sexport PATH=\"$HOME/.odinup/bin:$PATH\"%s\n", CYAN, RESET)
	}
}

find_executable :: proc(base_dir: string, exe_name: string) -> string {
	// 1. Direct location check
	direct, _ := filepath.join([]string{base_dir, exe_name}, context.allocator)
	if os.exists(direct) {
		return direct
	}

	// 2. Check within the first nested extraction folder (standard GitHub payload structure)
	f, err := os.open(base_dir)
	if err == os.ERROR_NONE {
		defer os.close(f)
		fis, _ := os.read_dir(f, -1, context.allocator)
		for fi in fis {
			if os.is_dir(fi.fullpath) {
				inner, _ := filepath.join([]string{base_dir, fi.name, exe_name}, context.allocator)
				if os.exists(inner) {
					return inner
				}
			}
		}
	}
	return ""
}
