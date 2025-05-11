variable "cidr_block" {
 type    = string
 default = "10.0.0.0/8"

}

output "cidr" {
    value =var.cidr_block
}
#run using: terraform apply -var "cidr_block=172.0.0.0/16"
#envt variable - more precedence than default
    # export TF_VAR_cidr_block=172.0.0.0/16
    # terraform apply
    # terraform apply -var "cidr_block=172.0.0.0/16"
# or tfvar file - higher precedence
    #terraform apply -var-file=values.tfvars
