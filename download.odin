package odinup

import "core:fmt"
import "core:os"

download_asset :: proc(version: string, asset_url: string, dest_file: string) {
	//fmt.printf("Downloading %s from %s...\n", version, asset_url)
	fmt.printf("%sDownloading %s...%s\n", B_CYAN, version, RESET)
	fmt.printf("%sURL: %s%s\n", GRAY, asset_url, RESET)
	cmd := fmt.tprintf("curl -L --progress-bar \"%s\" -o \"%s\"", asset_url, dest_file)
	if run_command(cmd) != 0 {
		fmt.eprintf("%s✖ Error: Failed to download the release asset.%s\n", RED, RESET)
		os.exit(1)
	}
}

extract_tar :: proc(archive: string, dest: string) {
	// cmd := fmt.tprintf("tar -xzf \"%s\" -C \"%s\"", archive, dest)
	fmt.printf("%s📂 Extracting tar.gz archive...%s\n", YELLOW, RESET)
	cmd := fmt.tprintf("tar -xzf \"%s\" -C \"%s\"", archive, dest)
	if run_command(cmd) != 0 {
		fmt.eprintf("%s✖ Error: Failed to extract tar archive.%s\n", RED, RESET)
		os.exit(1)
	}
}

extract_zip :: proc(archive: string, dest: string) {
	fmt.printf("%s📂 Extracting zip archive...%s\n", YELLOW, RESET)
	cmd := ""
	if ODIN_OS == .Windows {
		cmd = fmt.tprintf("tar -xf \"%s\" -C \"%s\"", archive, dest)
	} else {
		cmd = fmt.tprintf("unzip -q \"%s\" -d \"%s\"", archive, dest)
	}

	if run_command(cmd) != 0 {
		fmt.eprintf("%s✖ Error: Failed to extract zip archive.%s\n", RED, RESET)
		os.exit(1)
	}
}
