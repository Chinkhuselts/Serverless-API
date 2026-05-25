# api.tf

# 1. Create the Serverless Application
resource "oci_functions_application" "ibm_portfolio_app" {
  compartment_id = var.tenancy_ocid
  display_name   = "ibm-portfolio-app"
  subnet_ids     = [oci_core_subnet.serverless_subnet.id]
}

# 2. Create the Function (Pointing to your Docker Image)
resource "oci_functions_function" "python_api_func" {
  application_id = oci_functions_application.ibm_portfolio_app.id
  display_name   = "python-hello-world"
  image          = "arn.ocir.io/axa893agqpsj/ibm-portfolio/python-api:v1"
  memory_in_mbs  = 128
}

# 3. Create the API Gateway (The Public Front Door)
resource "oci_apigateway_gateway" "public_api_gateway" {
  compartment_id = var.tenancy_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.serverless_subnet.id
  display_name   = "ibm-portfolio-gateway"
}

# 4. Create the Deployment (Routing Rules)
resource "oci_apigateway_deployment" "api_deployment" {
  compartment_id = var.tenancy_ocid
  gateway_id     = oci_apigateway_gateway.public_api_gateway.id
  path_prefix    = "/api"
  
  specification {
    routes {
      path    = "/hello"
      methods = ["ANY"]
      backend {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.python_api_func.id
      }
    }
  }
}

# 5. The Grand Finale: Output the Live URL!
output "live_api_url" {
  description = "Click this link to test your live Serverless API"
  value       = "${oci_apigateway_deployment.api_deployment.endpoint}/hello"
}
resource "oci_identity_policy" "api_gateway_invoke_policy" {
  compartment_id = var.tenancy_ocid
  name           = "ibm-portfolio-gateway-policy"
  description    = "Allows the API Gateway to invoke Python Serverless Functions"
  
  statements = [
    "Allow any-user to use functions-family in tenancy where ALL {request.principal.type='apigateway', request.resource.compartment.id='${var.tenancy_ocid}'}"
  ]
}
