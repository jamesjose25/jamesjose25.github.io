# Artifactory and `npm`

An increasing number of components in the IIB v10 and ACE v11 are written in JavaScript and are managed as separate components which get published to an internal NPM repository. We need to install a number of these packages during the product build, and so access to our NPM repository must be configured before starting.

1. Login to the [Artifactory website](https://na.artifactory.swg-devops.com/artifactory/webapp/) using your w3id
2. Click on your email address in the top right corner to open your User Profile
3. Enter your w3 password again to unlock the profile
4. Copy your API key
5. In a terminal, use curl to download your npmrc file, replacing YOUR_EMAIL and YOUR_API_KEY with the appropriate values:
    * Linux and macOS:
      ```
      $ curl -X GET -u YOUR_EMAIL:YOUR_API_KEY "https://na.artifactory.swg-devops.com/artifactory/api/npm/auth" > ~/.npmrc
      $ echo "registry=https://na.artifactory.swg-devops.com/artifactory/api/npm/appconnect-npm" >> ~/.npmrc
      ```
    * Windows:
      ```
      curl -X GET -u YOUR_EMAIL:YOUR_API_KEY "https://na.artifactory.swg-devops.com/artifactory/api/npm/auth" > %USERPROFILE%\.npmrc
      echo registry=https://na.artifactory.swg-devops.com/artifactory/api/npm/appconnect-npm >> %USERPROFILE%\.npmrc
      ```
6. Once completed your `.npmrc` file should look like the example shown below:
   ```
    _auth=<npm token>
    email=<intranet id>
    always-auth=true
    package-lock=false
    registry=https://na.artifactory.swg-devops.com/artifactory/api/npm/appconnect-npm
    ```

You only need to do this step once, but you may need to repeat it if your Artifactory token gets revoked. The token does not expire at the usual cadence unlike the w3 password.