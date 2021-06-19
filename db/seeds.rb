# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# agrego rol predeterminado para usuarios comunes
Role.create!(name: 'user')
Role.create!(name: 'admin')
Role.create!(name: 'god')

user = User.create!(name: 'elpepe', login: 'usuario pepe', password: 'Elpepe1234')

user = User.create!(name: 'Foo', login: 'admin', password: 'Admin1234')
user.add_role('admin')

user = User.create!(name: 'God', login: 'god', password: 'God123456')
user.add_role('god')
user.add_role('admin')

['Mendoza', 'Buenos Aires', "Cordoba", "San Juan", "San Luis", "Catamarca", "Salta", "Jujuy"].each do |prov|
  Province.create!(name: prov)
end