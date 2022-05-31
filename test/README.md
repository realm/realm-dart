# Running the tests

## Run integration tests against Atlas cluster on MongoDB cloud.

In order to run the tests that requires a backend, you need to setup a MongoDB cluster to run against.
A free-tier database should be enough for most contributors.

1) Log on to [MongoDB cloud](https://cloud.mongodb.com)
2) Create an organization, if you don't already have one. You may choose to create one specifically for the
purpose of these tests, if you prefer.
3) Create a separate project for the purpose of running the tests.
4) Build a database for the project. Choose a tier - FREE should service for most contributors. Use the Default
settings.
5) Add a user. Not really needed for the tests, but you cannot proceed without.
6) Add your current IP address to IP address access list. You may need to revisit this step, if your IP changes.
Or you can add a 0.0.0.0/0 entry to allow all IPs.
7) Go to "Access manager -> Project Access". Located at the top of the page. Create an API key for the project.
Ensure that all permissions are granted, and copy the public and private key before proceeding.
8) Note down the project id. It is the long number in the url (https://cloud.mongodb.com/v2/<project_id>/..).
You can also find it at the project settings page.
9) Find the cluster name in "Deployment -> Database" (located at the left of the page). Usually "Cluster0"
10) Setup environment variables locally:
```
BAAS_URL=https://realm.mongodb.com
BAAS_CLUSTER=<cluster_name> # probably Cluster0
BAAS_API_KEY=<public_key>
BAAS_PRIVATE_API_KEY=<private_key>
BAAS_PROJECT_ID=<project_id>
```
10) Now you can run `dart test` and it should include the integration tests.

If you are a MongoDB employee, you can instead choose to run the tests against [cloud-dev](https://cloud-dev.mongodb.com).
The procedure is the same, except you need to use your qa credentials instead.



## Run integration tests against the BaaS docker image

MongoDB employees can run a local docker image that hosts baas and a mongodb database. It is the recommended way to
do day-to-day development as it allows you to get into a clean slate with a single command.

### Prerequisites

1. You need a docker desktop license. Request one from OfficeIT ([example ticket](https://jira.mongodb.org/browse/OFFICEIT-67070))
2. Request API keys for BaaS - reach out to Tim Sedgwick or Mike O'Brien for help.
3. [Configure Docker for use with GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry) - you only need the authentication part. 
    * First create a new token in [GitHub](https://github.com/) [Creating a token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). Be sure to select the following permissions:
      - repo 
      - read:packages
      - write:packages
      - delete:packages

    * Don't forget to Copy the new token.

    * Then run the following commands:
      - For MacOS anf Linux:
      ```sh
        $ export CR_PAT=YOUR_TOKEN
        $ echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
      ```
      - For Windows:
      ```
        SET CR_PAT="YOUR_TOKEN"
        docker login ghcr.io -u USERNAME --password-stdin
      ```
    where:
    - USERNAME is your [GitHub](https://github.com/) username.
    - YOUR_TOKEN is the token copied from the previous step.

  * Enter your [GitHub](https://github.com/) password. And the output should be `> Login Succeeded`.

4. Take note of your local machine IP address (it has to be the actual IP address, not localhost or 127.0.0.1).
5. Run the docker image:

    Required variables:
    * `baas_hostname` is the IP address from step 4.
    * `baas_access_key` is the credentials we got in step 2.
    * `baas_secret_key` is the credentials we got in step 2.
    * `some_empty_folder` is a mount empty folder to /apps. If not done, the docker image will import a sample app which will mess up the test setup.
    * `baas_version` is the version of the image you'd like to use. See versions at [mongodb-realm-test-server](https://github.com/realm/ci/pkgs/container/ci%2Fmongodb-realm-test-server).
    
    For MacOS anf Linux:
    ```sh
    baas_hostname="10.0.1.123"
    baas_access_key="<public_key>" 
    baas_secret_key="<private_key>"
    some_empty_folder="$(mktemp -d)"
    baas_version="2022-05-16"

    docker run \
      -e MONGODB_REALM_HOSTNAME=$baas_hostname -e AWS_ACCESS_KEY_ID=$baas_access_key -e AWS_SECRET_ACCESS_KEY=$baas_secret_key \
      --mount type=bind,src=$some_empty_folder,dst=/apps \
      -u 1000:1000 \
      -p 9090:9090 -p 26000:26000 \
      -it \
      --rm \
      ghcr.io/realm/ci/mongodb-realm-test-server:$baas_version
    ```

    For Windows:
    ```
    SET baas_hostname=10.0.1.123
    SET baas_access_key="<public_key>"
    SET baas_secret_key="<private_key>"
    SET some_empty_folder="path to empty dir"
    SET baas_version=2022-05-16

    docker run -e MONGODB_REALM_HOSTNAME=%baas_hostname% -e AWS_ACCESS_KEY_ID=%baas_access_key% -e AWS_SECRET_ACCESS_KEY=%baas_secret_key --mount type=bind,src=%some_empty_folder%,dst=/apps -u 1000:1000 -p 9090:9090 -p 26000:26000 -it --rm ghcr.io/realm/ci/mongodb-realm-test-server:%baas_version%
    ```
    where `docker run` arguments:
    * -p exposes the baas and mongodb ports to the host. 9090 is baas and 26000 is mongodb.
    * -it instructs Docker to allocate a pseudo-TTY connected to the container’s stdin; creating an interactive bash shell in the container.
    * --rm cleans up the container at exit. Omit this if you want to preserve the state between runs. Resume with [https://docs.docker.com/engine/reference/commandline/start/](https://docs.docker.com/engine/reference/commandline/start/)
    * For more information go to [docker run command](https://docs.docker.com/engine/reference/commandline/run/)

6. Setup the `BAAS_URL` environment variable. On macOS, this can be done for example by adding the following to your profile:

    For MacOS anf Linux:
    ```sh
      launchctl setenv BAAS_URL "http://$baas_hostname:9090"
    ```

    For Windows:
    ```
      SET BAAS_URL="http://%baas_hostname%:9090"
    ```

7. Now you can run `dart test` and it should include the integration tests.
