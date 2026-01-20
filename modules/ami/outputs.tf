
output "image_component" {
  value = aws_imagebuilder_component.wx.arn
}

output "x86_id" {
  value = tolist(aws_imagebuilder_image.wx_x86.output_resources[0].amis)[0].image
}

output "arm_id" {
  value = tolist(aws_imagebuilder_image.wx_arm.output_resources[0].amis)[0].image
}
