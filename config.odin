package odinup

import "core:fmt"
import "core:os"
import "core:path/filepath"

Config :: struct {
	home_dir:     string,
	versions_dir: string,
	odin_dir:     string,
	ols_dir:      string,
	bin_dir:      string,
}

cfg: Config

init_config :: proc() {
	home := os.get_env("ODINUP_HOME", context.allocator)
	if home == "" {
		user_profile := os.get_env("HOME", context.allocator)
		if user_profile == "" {
			user_profile = os.get_env("USERPROFILE", context.allocator) // Windows fallback
		}
		if user_profile == "" {
			fmt.eprintln("Could not determine user home directory. Please set ODINUP_HOME.")
			os.exit(1)
		}
		home, _ = filepath.join([]string{user_profile, ".odinup"}, context.allocator)
	}

	cfg.home_dir = home
	cfg.versions_dir, _ = filepath.join([]string{home, "versions"}, context.allocator)
	cfg.odin_dir, _ = filepath.join([]string{cfg.versions_dir, "odin"}, context.allocator)
	cfg.ols_dir, _ = filepath.join([]string{cfg.versions_dir, "ols"}, context.allocator)
	cfg.bin_dir, _ = filepath.join([]string{home, "bin"}, context.allocator)

	// We make sure the tree exists correctly
	ensure_dir(cfg.home_dir)
	ensure_dir(cfg.versions_dir)
	ensure_dir(cfg.odin_dir)
	ensure_dir(cfg.ols_dir)
	ensure_dir(cfg.bin_dir)
}

print_env :: proc() {
	if ODIN_OS == .Windows {
		fmt.println("REM Add the following directory to your PATH environment variable:")
		fmt.printf("REM %s\n", cfg.bin_dir)
	} else {
		fmt.printf("export PATH=\"%s:$PATH\"\n", cfg.bin_dir)
		fmt.println(
			"# Add the above line to your shell configuration file (e.g. ~/.bashrc, ~/.zshrc)",
		)
	}
}
