# Bike Images Directory

This directory contains bike images for the RevUp bike rental app.

## Bike Images Specifications:
- **Dimensions**: 500x300px (5:3 aspect ratio)
- **Format**: JPG or PNG
- **File Size**: Preferably under 400KB for optimal loading
- **Quality**: High resolution for crisp display

## Bike Categories and Types:
1. **Scooters**: honda_activa_6g.jpg, suzuki_access_125.jpg
2. **Sports Bikes**: royal_enfield_classic_350.jpg, ktm_duke_200.jpg, tvs_apache_rtr_160.jpg, bajaj_pulsar_ns200.jpg, yamaha_fz_s_v3.jpg
3. **Commuter Bikes**: hero_splendor_plus.jpg, honda_cb_shine.jpg
4. **Generic Types**: scooter.jpg, sports_bike.jpg, naked.jpg, cruiser.jpg, commuter.jpg, mountain_bike.jpg, sport.jpg

## Network Images:
The app currently uses high-quality motorcycle and scooter images from Unsplash API. Local images in this directory serve as offline fallbacks.

## Image Loading Strategy:
1. Try to load specific bike model image by name
2. Fallback to bike type image (scooter, sports bike, etc.)
3. Fallback to local asset images if available
4. Final fallback to bike icon

## Usage:
- Network images load first for the best visual experience
- Local images are used when network is unavailable
- Bike icon serves as the final fallback
