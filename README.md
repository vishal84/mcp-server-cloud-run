# mcp-server-cloud-run

An example MCP server deployable to Cloud Run that is secured by authentication and requires an identity token to access.

Full Codelab tutorial available here:
https://codelabs.developers.google.com/codelabs/cloud-run/how-to-deploy-a-secure-mcp-server-on-cloud-run

## To run this example

### Install dependencies
From the project root directory run the following command:

```
uv sync
```

### Authenticate `gcloud` CLI
Authenticate the `gcloud` CLI using the following command:
```
gcloud auth application-default login
```

This will trigger an OAuth 2.0 flow and will prompt you to login to your Google account. Log in to your account using your credentials return to your termianl once completed.

### Deploy MCP server to Cloud Run
Set the environment variables related to your GCP project in the `set_env.sh` script. From the shell terminal run the following to source its variables:
```
chmod +x set_env.sh
source set_env.sh
```

Run the following command to deploy the MCP server to Cloud Run:
```
gcloud run deploy zoo-mcp-server \
    --no-allow-unauthenticated \
    --project=$GOOGLE_CLOUD_PROJECT \
    --region=$GOOGLE_CLOUD_LOCATION \
    --source=. \
    --labels=demo=mcp-server-cloud-run
```

### Bind `Cloud Run: Invoker` role to end user account
The `--no-allow-unauthenticated` flag of the Cloud Run deployment command secures the MCP server by requiring an `Authorization` header with a valid `Bearer <token>` is presented to the server to allow traffic through.

Run the following command to give your user account permissions to invoke the MCP server on Cloud Run.
```
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member=user:$(gcloud config get-value account) \
    --role='roles/run.invoker'
```

Save your Google Cloud credentials and project number in environment variables for the use in the Gemini CLI tool.
```
export PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")
export ID_TOKEN=$(gcloud auth print-identity-token)
```

You may need to re-run the command to export an ID_TOKEN if the token timteout expires.


## Use an MCP Client to use tools on the MCP Server
To test the MCP Server and its authentication requirement, you will need an MCP Client.

To quickly test this setup, you can use the `Gemini CLI`. To install it you can run the following command from your shell:
```
npm install -g @google/gemini-cli@latest
```

This will install the latest `Gemini CLI` and requires having node package manager (npm) installed.

### Configure `Gemini CLI` settings.json file
To tell the Gemini CLI to use your Cloud Run MCP Server with required Authentication parameters run the following in your terminal to set required environment variables.

```
export PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")
export ID_TOKEN=$(gcloud auth print-identity-token)
```

Open your Gemini CLI settings file:
```
vi ~/.gemini/settings.json
```


```
{
  "mcpServers": {
    "zoo-remote": {
      "httpUrl": "https://zoo-mcp-server-$PROJECT_NUMBER.$GOOGLE_CLOUD_LOCATION.run.app/mcp/",
      "headers": {
        "Authorization": "Bearer $ID_TOKEN"
      }
    }
  },
  "selectedAuthType": "cloud-shell",
  "hasSeenIdeIntegrationNudge": true
}
```

### Use one of the MCP Server's tools
Start the Gemini CLI from your shell:
```
gemini
```

List MCP tools available to the Gemini CLI (MCP Client):
```
/mcp
```

Ask gemini to find something in the zoo:
```
Where can I find walruses?
```
*You may need to tell the Gemini CLI to allow execution of the MCP tool running on the remote server.*

The output should indicate that an MCP server tool defined in `server.py` was used.