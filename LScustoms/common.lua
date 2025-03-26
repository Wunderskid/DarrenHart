-- common.lua
-- Vertalingen door Wunderskid (DJ Hart)

Locales = {
    ['en'] = {
        ['menu_title'] = 'Los Santos Customs',
        ['engine'] = 'Engine Upgrade',
        ['brakes'] = 'Brakes',
        ['suspension'] = 'Suspension',
        ['transmission'] = 'Transmission',
        ['armor'] = 'Armor',
        ['turbo'] = 'Turbo',
        ['repair'] = 'Repair',
        ['clean'] = 'Clean',
        ['purchase_success'] = 'Purchase successful!',
        ['not_enough_money'] = 'Not enough money!',
        ['vehicle_repaired'] = 'Vehicle repaired!',
        ['vehicle_cleaned'] = 'Vehicle cleaned!',
        ['turbo_added'] = 'Turbo installed!',
        ['turbo_removed'] = 'Turbo removed!',
        ['invalid_vehicle'] = 'This vehicle cannot be modified',
        ['no_vehicle'] = 'You are not in a vehicle'
    },
    ['nl'] = {
        ['menu_title'] = 'Los Santos Customs',
        ['engine'] = 'Motor Upgrade',
        ['brakes'] = 'Remmen',
        ['suspension'] = 'Ophanging',
        ['transmission'] = 'Transmissie',
        ['armor'] = 'Pantser',
        ['turbo'] = 'Turbo',
        ['repair'] = 'Reparatie',
        ['clean'] = 'Schoonmaken',
        ['purchase_success'] = 'Aankoop succesvol!',
        ['not_enough_money'] = 'Niet genoeg geld!',
        ['vehicle_repaired'] = 'Voertuig gerepareerd!',
        ['vehicle_cleaned'] = 'Voertuig schoongemaakt!',
        ['turbo_added'] = 'Turbo geïnstalleerd!',
        ['turbo_removed'] = 'Turbo verwijderd!',
        ['invalid_vehicle'] = 'Dit voertuig kan niet worden aangepast',
        ['no_vehicle'] = 'Je zit niet in een voertuig'
    }
}

function _U(str)
    return Locales['en'][str] or str
end