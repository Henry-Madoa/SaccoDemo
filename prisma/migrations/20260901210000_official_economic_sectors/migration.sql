-- The SACCO's official three-level economic classification (AL Economic Sectors / Subsectors /
-- Sub-subsectors, numeric 1000-8000 / 1100-8400 / 1110-8410 coding). Companion to 20260901200000,
-- which seeds the 8 top-level sectors. Written to be idempotent: on a fresh install where
-- 20260901200000 already loaded the numeric sectors, the DELETEs below match nothing and the
-- INSERTs no-op on conflict; on a DB that had the earlier placeholder codes, they are cleared.

UPDATE "loan" SET "sector_code" = NULL, "sub_sector_code" = NULL, "sub_subsector_code" = NULL
WHERE "sector_code" IS NOT NULL
  AND "sector_code" NOT IN ('1000','2000','3000','4000','5000','6000','7000','8000');

DELETE FROM "economic_subsubsector" WHERE "sector_code" NOT IN ('1000','2000','3000','4000','5000','6000','7000','8000');
DELETE FROM "economic_subsector"    WHERE "sector_code" NOT IN ('1000','2000','3000','4000','5000','6000','7000','8000');
DELETE FROM "economic_sector"       WHERE "code"        NOT IN ('1000','2000','3000','4000','5000','6000','7000','8000');

INSERT INTO "economic_sector" ("code", "name", "created_at", "created_by") VALUES
  ('1000', 'Agriculture',                              now()::text, 'system'),
  ('2000', 'Trade',                                    now()::text, 'system'),
  ('3000', 'Manufacturing And Servicing Industries',   now()::text, 'system'),
  ('4000', 'Education',                                now()::text, 'system'),
  ('5000', 'Human Health',                             now()::text, 'system'),
  ('6000', 'Land And Housing',                         now()::text, 'system'),
  ('7000', 'Finance, Investments And Insurance',       now()::text, 'system'),
  ('8000', 'Consumption And Social Services',          now()::text, 'system')
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "economic_subsector" ("sector_code", "code", "name") VALUES
  ('1000', '1100', 'Crop Farming'),
  ('1000', '1200', 'Animal Production'),
  ('1000', '1300', 'Agricultural Supporting Services'),
  ('1000', '1400', 'Agribusiness'),
  ('1000', '1500', 'Forestry And Logging'),
  ('2000', '2100', 'Wholesale And Retail'),
  ('2000', '2200', 'Transport'),
  ('2000', '2300', 'Hospitality'),
  ('2000', '2400', 'Foreign Trade'),
  ('3000', '3100', 'Cottage Industry'),
  ('3000', '3200', 'Servicing Industry'),
  ('3000', '3300', 'Information, Communication And Technology'),
  ('4000', '4100', 'Education And Related Services'),
  ('5000', '5100', 'Human Health And Related Services'),
  ('6000', '6100', 'Land'),
  ('6000', '6200', 'Housing'),
  ('7000', '7100', 'Microfinance'),
  ('7000', '7200', 'Commercial Banks'),
  ('7000', '7300', 'Mortgage Finance'),
  ('7000', '7400', 'Insurance'),
  ('7000', '7500', 'Investments'),
  ('8000', '8100', 'Utilities'),
  ('8000', '8200', 'Utilities'),
  ('8000', '8300', 'Consumer Durables'),
  ('8000', '8400', 'Social And Communal Expenses')
ON CONFLICT ("sector_code", "code") DO NOTHING;

INSERT INTO "economic_subsubsector" ("sector_code", "subsector_code", "code", "description") VALUES
  ('1000', '1100', '1110', 'Tea'),
  ('1000', '1100', '1120', 'Coffee'),
  ('1000', '1100', '1130', 'Sugarcane'),
  ('1000', '1100', '1140', 'Others, Cotton, Sisal Etc'),
  ('1000', '1100', '1150', 'Cereals Such As Maize, Wheat, Sorghum, Millet Etc'),
  ('1000', '1100', '1160', 'Legumes Such As Beans, Peas, Snow Peas, Cow Peas, French Beans Etc'),
  ('1000', '1100', '1170', 'Horticulture Crops Such As Vegetables, Fruits, Flowers'),
  ('1000', '1100', '1180', 'Roots & Tubers Such As Irish Potatoes, Sweet Potatoes And Cassava'),
  ('1000', '1200', '1210', 'Dairy Farming'),
  ('1000', '1200', '1220', 'Beef Production'),
  ('1000', '1200', '1230', 'Poultry Farming'),
  ('1000', '1200', '1240', 'Bee Keeping'),
  ('1000', '1200', '1250', 'Rabbit Farming'),
  ('1000', '1200', '1260', 'Sheep And Goat Rearing'),
  ('1000', '1200', '1270', 'Pig Farming'),
  ('1000', '1200', '1280', 'Others'),
  ('1000', '1300', '1310', 'Agricultural Machinery Such As Truck, Tractors And Other Farm Tools'),
  ('1000', '1300', '1320', 'Water, Irrigation And Supporting Services'),
  ('1000', '1300', '1330', 'Veterinary And Related Services'),
  ('1000', '1400', '1410', 'Agricultural Equipment And Accessories'),
  ('1000', '1400', '1420', 'Dealers In Agro-Chemicals, Seeds And Other Farm Inputs'),
  ('1000', '1400', '1430', 'Distribution Of Farm Produce'),
  ('1000', '1500', '1510', 'Agro-Forestry'),
  ('2000', '2100', '2110', 'Wholesale'),
  ('2000', '2100', '2120', 'Retail'),
  ('2000', '2200', '2210', 'Public Service Transport'),
  ('2000', '2200', '2220', 'Purchase Of Motorvehicle Accessories'),
  ('2000', '2200', '2230', 'Transportation Of Goods'),
  ('2000', '2300', '2310', 'Accommodation, Restaurants, Conference Facilities, Event Planning & Outside Catering, Theme Parks (Wet & Dry)'),
  ('2000', '2300', '2320', 'Schools And Kindergartens'),
  ('2000', '2300', '2330', 'Medical Clinics And Equipment'),
  ('2000', '2400', '2410', 'Import'),
  ('2000', '2400', '2420', 'Export'),
  ('3000', '3100', '3110', 'Jua Kali Industry'),
  ('3000', '3100', '3120', 'Small Scale Agricultural Produce Processing'),
  ('3000', '3100', '3130', 'Dressmaking Industry'),
  ('3000', '3100', '3140', 'Leather Tanning'),
  ('3000', '3100', '3150', 'Carving And Handcrafts'),
  ('3000', '3200', '3210', 'Motorvehicle Repairs'),
  ('3000', '3200', '3220', 'Professional Services Such As Barber Shops'),
  ('3000', '3200', '3230', 'Working Capital For Learning Institutions, Churches & Business Enterprises'),
  ('3000', '3200', '3240', 'Promotion Of Local Tourism'),
  ('3000', '3300', '3310', 'Computer Services And Internet'),
  ('3000', '3300', '3320', 'Computer Software And Hardware'),
  ('3000', '3300', '3330', 'Telecommunication Equipment'),
  ('4000', '4100', '4110', 'School Fees For Primary And Secondary Schools Including Shopping And Accomodation'),
  ('4000', '4100', '4120', 'College Fees, University Fees, Training Fees, Seminar Fees'),
  ('4000', '4100', '4130', 'Research And Scientific Activities Etc'),
  ('5000', '5100', '5110', 'Medical Bills, Purchase Of Medicine'),
  ('5000', '5100', '5120', 'Maternity Bills And Expenses'),
  ('6000', '6100', '6110', 'Purchase Of Plots'),
  ('6000', '6100', '6120', 'Land Purchase Services Such As Surveying And Valuation'),
  ('6000', '6200', '6210', 'Construction Of Multiple Residential Buildings'),
  ('6000', '6200', '6220', 'Construction Of Commercial Buildings'),
  ('6000', '6200', '6230', 'Construction Of Single Residential Dwelling Units'),
  ('6000', '6200', '6240', 'Renovations Of The Buildings'),
  ('7000', '7100', '7110', 'Payment To Microfinance Loans'),
  ('7000', '7200', '7210', 'Payment To Commercial Bank Loans'),
  ('7000', '7300', '7310', 'Purchase Of Residential Property / Payments To Mortgage Loans In Other Financial Institutions'),
  ('7000', '7400', '7410', 'Payment To Insurance Policies'),
  ('7000', '7500', '7510', 'Buying Of Sacco Shares'),
  ('7000', '7500', '7520', 'Purchase Of Quoted Shares, Unquoted Shares, Treasury Bills & Bonds, Commercial Papers, Unit Trusts And Other Securities'),
  ('7000', '7500', '7530', 'Paying Personal Debts To Non-Registered Institutions'),
  ('8000', '8100', '8110', 'Expenses Incurred Relating To Car And Electronic Repairs, Bills Like Electricity, Sewer, Water, Telephone'),
  ('8000', '8200', '8210', 'Household Necessities Like Food, Beverages And Basic Household Products'),
  ('8000', '8300', '8310', 'Goods That Do Not Wear Out Quickly Like Automobiles (Cars), Books, Household (Home Appliances, Consumer Electronics)'),
  ('8000', '8400', '8410', 'Burial Expenses, Wedding Expenses, Rites Of Passage Expenses')
ON CONFLICT ("sector_code", "subsector_code", "code") DO NOTHING;
