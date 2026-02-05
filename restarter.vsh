#!/usr/bin/env -S v crun

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
	log_path := '/var/log/${service}_restarter.log'
	log_message(log_path, 'Monitoring ${website} for "${word}", will restart ${service} on failure')
	for {
		check_and_restart(log_path, website, word, service)
		time.sleep(60 * time.second)
	}
}

fn log_message(log_path string, msg string) {
	line := '[${time.now()}] ${msg}\n'
	mut f := os.open_append(log_path) or {
		eprintln('Failed to open log file: ${err}')
		return
	}
	f.write_string(line) or {
		eprintln('Failed to write to log file: ${err}')
	}
	f.close()
}

fn check_and_restart(log_path string, website string, word string, service string) {
	log_message(log_path, 'Checking ${website}...')
	resp := http.get(website) or {
		log_message(log_path, 'Website is down: ${err}')
		restart_service(log_path, service)
		return
	}
	if resp.status_code < 200 || resp.status_code >= 400 {
		log_message(log_path, 'Bad status code: ${resp.status_code}')
		restart_service(log_path, service)
		return
	}
	if !resp.body.contains(word) {
		log_message(log_path, 'Word "${word}" not found in response')
		restart_service(log_path, service)
		return
	}
	log_message(log_path, 'OK')
}

fn restart_service(log_path string, service string) {
	log_message(log_path, 'Restarting service: ${service}')
	result := os.execute('systemctl restart ${service}')
	if result.exit_code != 0 {
		log_message(log_path, 'ERROR: Failed to restart service: ${result.output}')
	} else {
		log_message(log_path, 'Service restarted successfully')
	}
}
