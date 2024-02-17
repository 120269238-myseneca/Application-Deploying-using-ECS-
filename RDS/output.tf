output "DBHOST" {
  value = aws_db_instance.my_rds.address
}

output "DBPORT" {
  value = "3306"
}

output "DBUSER" {
  value = "dbadmin"
}

output "DBPWD" {
  value = "sudeepsaurabh01"
}

output "DATABASE" {
  value = "employee"

}