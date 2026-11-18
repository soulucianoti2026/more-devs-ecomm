#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');

function fail(message) {
  console.error(message);
  process.exit(1);
}

if (process.argv.length > 3) {
  fail('Usage: node tool/configure-firebase.cjs [private-config.json]');
}

let source;
try {
  source = process.argv[2]
    ? fs.readFileSync(process.argv[2], 'utf8')
    : process.env.FIREBASE_ANDROID_CONFIG;
} catch {
  fail('Cannot read the private Firebase configuration file.');
}
if (!source) {
  fail('Provide a private JSON file or set FIREBASE_ANDROID_CONFIG.');
}

let config;
try {
  config = JSON.parse(source);
} catch {
  fail('Invalid Firebase configuration JSON. No file was written.');
}

if (config?.project_info?.project_id !== 'ecomfirebaseapp-73b2a') {
  fail('The configuration does not belong to the expected Firebase project.');
}
const client = Array.isArray(config.client) && config.client.find(
  item => item?.client_info?.android_client_info?.package_name ===
    'com.example.more_devs_do_zero'
);
if (!client || !Array.isArray(client.api_key) || !client.api_key.some(item =>
  typeof item?.current_key === 'string' && /^AIza[0-9A-Za-z_-]{35}$/.test(item.current_key)
)) {
  fail('The Android application or its API key is missing or invalid.');
}

const target = path.resolve(__dirname, '../android/app/google-services.json');
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, JSON.stringify(config, null, 2) + '\n', { mode: 0o600 });
console.log('Local Android Firebase configuration created. Keep it out of Git.');
