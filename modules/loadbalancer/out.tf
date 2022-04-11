output "target_group_arns" {
  value = [
    for tg in module.tg : tg.target_group_arns
  ]
}
