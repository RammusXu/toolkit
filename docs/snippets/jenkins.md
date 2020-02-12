## curl trigger build
```
curl -i -d "targetEnv=demo&myArg=helloWorld" -u admin:a_md5_context -XPOST https://my_domain/job/my_job/buildWithParameters
```