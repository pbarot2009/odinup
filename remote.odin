package odinup

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"

Github_Asset :: struct {
	name:                 string,
	browser_download_url: string,
}

Github_Release :: struct {
	tag_name: string,
	assets:   []Github_Asset,
}

fetch_releases :: proc() -> []Github_Release {
	url := "https://api.github.com/repos/odin-lang/Odin/releases"
	tmp_file, _ := filepath.join([]string{cfg.home_dir, "releases.json"}, context.allocator)
	defer os.remove(tmp_file)

	// Download JSON strictly using curl (standardized across Unix + modern Windows)
	cmd := fmt.tprintf("curl -s -L \"%s\" -o \"%s\"", url, tmp_file)
	if run_command(cmd) != 0 {
		fmt.eprintfln(
			"%s%s ERROR %s %sFailed to fetch releases from GitHub using curl. %s",
			BG_RED,
			BLACK,
			RESET,
			RED,
			RESET,
		)
		os.exit(1)
	}

	data, read_err := os.read_entire_file_from_path(tmp_file, context.allocator)
	if read_err != nil {
		fmt.eprintfln(
			"%s%s ERROR %s %sFailed to read downloaded releases.json %s",
			BG_RED,
			BLACK,
			RESET,
			RED,
			RESET,
		)
		os.exit(1)
	}
	defer delete(data)

	releases: []Github_Release
	err := json.unmarshal(data, &releases)
	if err != nil {
		fmt.eprintln(
			"%s%s ERROR %s %sFailed to parse GitHub API JSON response. %s",
			BG_RED,
			BLACK,
			RESET,
			RED,
			RESET,
		)
		os.exit(1)
	}

	return releases
}

fetch_releases_ols :: proc() -> []Github_Release {
	url := "https://api.github.com/repos/DanielGavin/ols/releases"
	tmp_file, _ := filepath.join([]string{cfg.home_dir, "releases.json"}, context.allocator)
	defer os.remove(tmp_file)

	// Download JSON strictly using curl (standardized across Unix + modern Windows)
	cmd := fmt.tprintf("curl -s -L \"%s\" -o \"%s\"", url, tmp_file)
	if run_command(cmd) != 0 {
		fmt.eprintln(
			"%s%s ERROR %s %sFailed to fetch releases from GitHub using curl. %s",
			BG_RED,
			BLACK,
			RESET,
			RED,
			RESET,
		)
		os.exit(1)
	}

	data, read_err := os.read_entire_file_from_path(tmp_file, context.allocator)
	if read_err != nil {
		fmt.eprintln(
			"%s%s ERROR %s %sFailed to read downloaded releases.json %s",
			BG_RED,
			BLACK,
			RESET,
			RED,
			RESET,
		)
		os.exit(1)
	}
	defer delete(data)

	releases: []Github_Release
	err := json.unmarshal(data, &releases)
	if err != nil {
		fmt.eprintln(
			"%s%s ERROR %s %sFailed to parse GitHub API JSON response. %s",
			BG_RED,
			BLACK,
			RESET,
			RED,
			RESET,
		)
		os.exit(1)
	}

	return releases
}

list_remote :: proc(ols: bool) {
	fmt.printf("%s🔍 Fetching remote versions from GitHub...%s\n", B_YELLOW, RESET)
	releases := ols ? fetch_releases_ols() : fetch_releases()

	count := 0
	for rel in releases {
		fmt.printf("  %-15s", rel.tag_name)
		count += 1
		if count % 4 == 0 do fmt.println() // New line every 4 versions
	}
	fmt.println("\n")
}
