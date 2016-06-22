# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

State.create(name: "Puhelu", filter: true)
State.create(name: "Backoffice", filter: true)
State.create(name: "Tauko", filter: true)
State.create(name: "Chat", filter: true)
State.create(name: "Palaveri", filter: true)
State.create(name: "Teljentä", filter: true)
State.create(name: "Vapaa", filter: true)
State.create(name: "Jälkikirjaus", filter: true)
State.create(name: "Vikapäivystys", filter: true)
State.create(name: "Ruokatunti", filter: true)

Team.create(name: "Helpdesk", filter: true)
Team.create(name: "Hakijapalvelut", filter: false)
Team.create(name: "Opiskelijaneuvonta", filter: false)
Team.create(name: "OrangeContact 1", filter: false)
Team.create(name: "Puhelinvaihde", filter: false)
Team.create(name: "Uaf", filter: false)

