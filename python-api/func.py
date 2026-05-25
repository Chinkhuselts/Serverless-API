import io
import json
import logging
from fdk import response

def handler(ctx, data: io.BytesIO = None):
    logging.getLogger().info("IBM Portfolio API invoked.")
    
    name = "World"
    
    # Try to read incoming JSON data (if the user sends a POST request)
    try:
        body = json.loads(data.getvalue())
        name = body.get("name", "World")
    except (Exception, ValueError) as ex:
        logging.getLogger().info(f"No JSON body found: {str(ex)}")

    # The payload we are sending back
    api_response = {
        "status": 200,
        "message": f"Hello {name}! This serverless API was built for the IBM Cloud Developer portfolio.",
        "tech_stack": ["Oracle Cloud", "Terraform", "Python", "Serverless"]
    }

    # Return the HTTP response
    return response.Response(
        ctx, 
        response_data=json.dumps(api_response),
        headers={"Content-Type": "application/json"}
    )
