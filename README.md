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
Set environment variables related to your GCP project:
```
export PROJECT_ID="gsi-agentspace"
export REGION="us-central1"
````

Run the following command to deploy the MCP server to Cloud Run:
```
gcloud run deploy zoo-mcp-server \
    --no-allow-unauthenticated \
    --project=$PROJECT \
    --region=$REGION \
    --source=. \
    --labels=demo=mcp-server-cloud-run
    --allow-unauthenticated-proxy
```
