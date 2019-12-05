const core = require('@actions/core');
// const github = require('@actions/github');
const exec = require('@actions/exec');
const fs = require('fs');
const path = require('path');

async function run() {
    try {

        if (process.env['GHR_USERNAME'] && process.env['GHR_PASSWORD']) {
            console.log('##[Login GPR]');
            await exec.exec(`docker login docker.pkg.github.com -u ${process.env['GHR_USERNAME']} -p ${process.env['GHR_PASSWORD']}`);
        }
        if (process.env['GCLOUD_AUTH']) {
            console.log('##[Login GCR]');
            file_gcloud_json = path.join(process.env['HOME'],'gcloud.json')

            fs.writeFileSync(
                file_gcloud_json,
                Buffer.from(process.env['GCLOUD_AUTH'],'base64')
            );

            await exec.exec(`gcloud auth activate-service-account --key-file=${file_gcloud_json}`);
            await exec.exec('bash -c "yes | gcloud auth configure-docker"');
        }

    } catch (error) {
        core.setFailed(error.message);
    }
}

run();

