output "image_component" {
  value = aws_imagebuilder_component.pcs.arn
}

output "x86_id" {
  value = tolist(aws_imagebuilder_image.pcs_x86.output_resources[0].amis)[0].image
}

output "arm_id" {
  value = tolist(aws_imagebuilder_image.pcs_arm.output_resources[0].amis)[0].image
}
