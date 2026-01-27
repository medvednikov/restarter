#!/usr/bin/env -S v run

import net.http
import os
import time

fn main() {
	if os.args.len < 4 {
		eprintln('Usage: ./restarter.vsh <website> <word> <service>')
		eprintln('Example: ./restarter.vsh https://example.com "Welcome" nginx')
		exit(1)
	}
	website := os.args[1]
	word := os.args[2]
	service := os.args[3]
	println('Monitoring ${website} for "${word}", will restart ${service} on failure')
	for {
		check_and_restart(website, word, service)
		time.sleep(60 * time.second)
	}
}

fn check_and_restart(website string, word string, service string) {
	println('[${time.now()}] Checking ${website}...')
	resp := http.get(website) or {
		println('Website is down: ${err}')
		restart_service(service)
		return
	}
	if resp.status_code < 200 || resp.status_code >= 400 {
		println('Bad status code: ${resp.status_code}')
		restart_service(service)
		return
	}
	if !resp.body.contains(word) {
		println('Word "${word}" not found in response')
		restart_service(service)
		return
	}
	println('OK')
}

fn restart_service(service string) {
	println('Restarting service: ${service}')
	result := os.execute('systemctl restart ${service}')
	if result.exit_code != 0 {
		eprintln('Failed to restart service: ${result.output}')
	} else {
		println('Service restarted successfully')
	}
}
