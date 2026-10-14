import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../models/User.js';
import Institution from '../models/Institution.js';
import Equipment from '../models/Equipment.js';
import Request from '../models/Request.js';
import Notification from '../models/Notification.js';

dotenv.config();

const SEED_DATA = {
  institutions: [
    {
      name: 'Stanford Bioengineering Research Core',
      type: 'university',
      description: 'Advanced cellular imaging, spectroscopy, and high-throughput biophysical instrumentation core facility.',
      address: '443 Via Ortega, Shriram Center',
      city: 'Stanford',
      state: 'CA',
      postalCode: '94305',
      country: 'United States',
      contactEmail: 'bio-core@stanford.edu',
      contactNumber: '+1 (650) 723-2300',
      verificationStatus: 'verified',
    },
    {
      name: 'MIT Materials Systems & NanoLab',
      type: 'university',
      description: 'Precision nanoscale characterization, surface metrology, and high-frequency analytical electronics.',
      address: '77 Massachusetts Avenue, Building 13',
      city: 'Cambridge',
      state: 'MA',
      postalCode: '02139',
      country: 'United States',
      contactEmail: 'nanolab@mit.edu',
      contactNumber: '+1 (617) 253-1000',
      verificationStatus: 'verified',
    },
    {
      name: 'UC Berkeley Quantitative Bioscience Core',
      type: 'university',
      description: 'Shared bio-analytical instrumentation facility dedicated to structural biology and molecular pharmacology.',
      address: '2151 Berkeley Way',
      city: 'Berkeley',
      state: 'CA',
      postalCode: '94720',
      country: 'United States',
      contactEmail: 'qb3@berkeley.edu',
      contactNumber: '+1 (510) 643-8582',
      verificationStatus: 'verified',
    },
    {
      name: 'Salk Institute for Biological Studies',
      type: 'research_institute',
      description: 'Internationally renowned neuroscience, genetics, and plant biology research center.',
      address: '10010 N Torrey Pines Rd',
      city: 'La Jolla',
      state: 'CA',
      postalCode: '92037',
      country: 'United States',
      contactEmail: 'shared-resources@salk.edu',
      contactNumber: '+1 (858) 453-4100',
      verificationStatus: 'verified',
    },
  ],
  users: [
    {
      fullName: 'Dr. Elena Rostova',
      email: 'erostova@stanford.edu',
      password: 'Password123!',
      contactNumber: '+1 (650) 555-0142',
      department: 'Department of Bioengineering',
      title: 'Principal Investigator',
      role: 'lab_admin',
      institutionIndex: 0,
    },
    {
      fullName: 'Prof. Marcus Chen',
      email: 'mchen@mit.edu',
      password: 'Password123!',
      contactNumber: '+1 (617) 555-0199',
      department: 'Materials Science & Engineering',
      title: 'Senior Faculty',
      role: 'faculty',
      institutionIndex: 1,
    },
    {
      fullName: 'Dr. Sarah Al-Mansoor',
      email: 'salmansoor@berkeley.edu',
      password: 'Password123!',
      contactNumber: '+1 (510) 555-0133',
      department: 'Molecular & Cell Biology',
      title: 'Facility Manager',
      role: 'lab_admin',
      institutionIndex: 2,
    },
    {
      fullName: 'Julian Vance',
      email: 'jvance@salk.edu',
      password: 'Password123!',
      contactNumber: '+1 (858) 555-0188',
      department: 'Neurobiology Laboratory',
      title: 'Postdoctoral Fellow',
      role: 'researcher',
      institutionIndex: 3,
    },
  ],
  equipment: [
    {
      title: 'Olympus IX83 Inverted Fluorescence Microscope',
      description: 'Fully motorized inverted microscope optimized for live-cell imaging, multi-channel fluorescence, and time-lapse microscopy. Equipped with high-speed filter wheels, Z-drift compensator, and environmental incubator chamber.',
      category: 'microscopy',
      condition: 'like_new',
      listingType: 'both',
      rentalPrice: 75,
      rentalPricingUnit: 'hour',
      purchasePrice: 42000,
      availability: 'available',
      featured: true,
      userIndex: 0,
      institutionIndex: 0,
      location: { building: 'Shriram Center', room: 'B-104', city: 'Stanford', state: 'CA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_olympus_ix83_cover',
          isCover: true,
        },
        {
          url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_olympus_ix83_detail',
          isCover: false,
        },
      ],
      technicalSpecs: [
        { key: 'Magnification', value: '10x, 20x, 40x Oil, 100x TIRF' },
        { key: 'Illumination', value: '7-channel Lumencor SPECTRA X Light Engine' },
        { key: 'Camera', value: 'Hamamatsu ORCA-Fusion BT sCMOS' },
        { key: 'Software', value: 'cellSens Dimension with Deconvolution' },
      ],
    },
    {
      title: 'Beckman Coulter Optima XPN-100 Ultracentrifuge',
      description: 'Premium floor-standing ultracentrifuge delivering up to 100,000 RPM (802,000 x g). Features remote monitoring, bio-safety HEPA filtration, and vacuum system for subcellular fractionation, viral vector purification, and protein assembly analysis.',
      category: 'centrifugation',
      condition: 'excellent',
      listingType: 'rent',
      rentalPrice: 350,
      rentalPricingUnit: 'day',
      purchasePrice: null,
      availability: 'available',
      featured: true,
      userIndex: 1,
      institutionIndex: 1,
      location: { building: 'Building 13 NanoLab', room: '101', city: 'Cambridge', state: 'MA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_beckman_ultracentrifuge',
          isCover: true,
        },
      ],
      technicalSpecs: [
        { key: 'Max Speed', value: '100,000 RPM' },
        { key: 'Max RCF', value: '802,000 x g' },
        { key: 'Available Rotors', value: 'SW 32 Ti (Swinging Bucket), 70 Ti (Fixed Angle)' },
        { key: 'Temperature Control', value: '0°C to 40°C in 1°C increments' },
      ],
    },
    {
      title: 'Agilent Cary 60 UV-Vis Spectrophotometer',
      description: 'Efficient, accurate double-beam spectrophotometer with xenon flash lamp technology. Suitable for kinetics measurements, DNA/RNA quantification, and protein concentration assays with zero sample photobleaching.',
      category: 'spectroscopy',
      condition: 'excellent',
      listingType: 'both',
      rentalPrice: 180,
      rentalPricingUnit: 'day',
      purchasePrice: 16500,
      availability: 'available',
      featured: true,
      userIndex: 2,
      institutionIndex: 2,
      location: { building: 'Berkeley Way West', room: '320', city: 'Berkeley', state: 'CA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_agilent_spectro',
          isCover: true,
        },
      ],
      technicalSpecs: [
        { key: 'Wavelength Range', value: '190 nm – 1100 nm' },
        { key: 'Scan Rate', value: 'Up to 24,000 nm/min' },
        { key: 'Light Source', value: 'Xenon Flash Lamp (10-year lifespan)' },
        { key: 'Optical Design', value: 'Double beam Czerny-Turner monochromator' },
      ],
    },
    {
      title: 'Tektronix MSO64B Mixed Signal Oscilloscope 4-GHz',
      description: '4-channel mixed signal oscilloscope offering 4 GHz bandwidth, 50 GS/s sample rate, and 12-bit vertical resolution. Ideal for high-speed digital analysis, RF laboratory testing, and advanced sensor signal characterization.',
      category: 'electronics',
      condition: 'like_new',
      listingType: 'rent',
      rentalPrice: 450,
      rentalPricingUnit: 'week',
      purchasePrice: null,
      availability: 'available',
      featured: false,
      userIndex: 1,
      institutionIndex: 1,
      location: { building: 'Building 13 NanoLab', room: '144', city: 'Cambridge', state: 'MA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_tektronix_oscilloscope',
          isCover: true,
        },
      ],
      technicalSpecs: [
        { key: 'Bandwidth', value: '4 GHz on all channels' },
        { key: 'Sample Rate', value: '50 GS/s real-time' },
        { key: 'Resolution', value: '12-bit ADC (up to 16 bits in Hi-Res mode)' },
        { key: 'Display', value: '15.6-inch HD Touch Display' },
      ],
    },
    {
      title: 'Mettler Toledo XPR205 Analytical Microbalance',
      description: 'Exceptional weighing performance with 0.01 mg readability and built-in electrostatic detection and elimination. Includes SmartSens infrared hands-free draft shield doors.',
      category: 'analytical_chemistry',
      condition: 'like_new',
      listingType: 'buy',
      rentalPrice: null,
      rentalPricingUnit: 'day',
      purchasePrice: 9800,
      availability: 'available',
      featured: false,
      userIndex: 0,
      institutionIndex: 0,
      location: { building: 'Shriram Center', room: 'A-201', city: 'Stanford', state: 'CA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1628771065518-0d82f1938462?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_mettler_balance',
          isCover: true,
        },
      ],
      technicalSpecs: [
        { key: 'Capacity', value: '220 g' },
        { key: 'Readability', value: '0.01 mg' },
        { key: 'Repeatability', value: '0.007 mg' },
        { key: 'Calibration', value: 'proFACT Advanced internal automatic calibration' },
      ],
    },
    {
      title: 'Thermo Scientific Heracell VIOS 160i CO2 Incubator',
      description: 'Sterile cell culture incubator with copper chamber interior, ISO Class 5 HEPA continuous air filtration, and 180°C on-demand dry heat sterilization cycle.',
      category: 'cell_culture',
      condition: 'excellent',
      listingType: 'rent',
      rentalPrice: 200,
      rentalPricingUnit: 'week',
      purchasePrice: null,
      availability: 'available',
      featured: false,
      userIndex: 3,
      institutionIndex: 3,
      location: { building: 'East Building Salk', room: 'EB-20', city: 'La Jolla', state: 'CA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1579165466791-788226ab77b6?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_heracell_incubator',
          isCover: true,
        },
      ],
      technicalSpecs: [
        { key: 'Chamber Volume', value: '165 Liters (5.8 cu. ft.)' },
        { key: 'CO2 Sensor', value: 'Infrared (IR) Sensor' },
        { key: 'Decontamination', value: '180°C overnight cycle' },
        { key: 'Chamber Material', value: '100% Solid Antimicrobial Copper' },
      ],
    },
    {
      title: 'Buchi Rotavapor R-300 Professional Evaporator System',
      description: 'Comprehensive rotary evaporation system with automated heating bath, dynamic vacuum controller, and recirculating chiller F-305. Ideal for gentle solvent distillation and purification.',
      category: 'general_lab',
      condition: 'good',
      listingType: 'both',
      rentalPrice: 120,
      rentalPricingUnit: 'day',
      purchasePrice: 7200,
      availability: 'available',
      featured: false,
      userIndex: 2,
      institutionIndex: 2,
      location: { building: 'Latimer Hall', room: '412', city: 'Berkeley', state: 'CA' },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?q=80&w=1200&auto=format&fit=crop',
          publicId: 'seed_buchi_rotavapor',
          isCover: true,
        },
      ],
      technicalSpecs: [
        { key: 'Rotation Speed', value: '10 – 280 RPM' },
        { key: 'Bath Temperature', value: '20°C – 220°C (Oil/Water)' },
        { key: 'Vacuum Range', value: '1400 to 0 mbar' },
        { key: 'Glassware', value: 'Diagonal Assembly V with safety plastic coating' },
      ],
    },
  ],
};

export const populateData = async () => {
  console.log('[Seed] Clearing existing collections...');
  await Promise.all([
    User.deleteMany({}),
    Institution.deleteMany({}),
    Equipment.deleteMany({}),
    Request.deleteMany({}),
    Notification.deleteMany({}),
  ]);

  console.log('[Seed] Creating Institutions...');
  const createdInstitutions = await Institution.insertMany(SEED_DATA.institutions);

  console.log('[Seed] Creating Users...');
  const createdUsers = [];
  for (const u of SEED_DATA.users) {
    const passwordHash = await User.hashPassword(u.password);
    const user = await User.create({
      fullName: u.fullName,
      email: u.email.toLowerCase(),
      passwordHash,
      contactNumber: u.contactNumber,
      department: u.department,
      title: u.title,
      role: u.role,
      institution: createdInstitutions[u.institutionIndex]._id,
      accountStatus: 'active',
      lastLogin: new Date(),
    });
    createdUsers.push(user);
  }

  console.log('[Seed] Creating Equipment listings...');
  const createdEquipment = [];
  for (const eq of SEED_DATA.equipment) {
    const item = await Equipment.create({
      ...eq,
      ownerUser: createdUsers[eq.userIndex]._id,
      ownerInstitution: createdInstitutions[eq.institutionIndex]._id,
    });
    createdEquipment.push(item);
  }

  console.log('[Seed] Creating sample Request...');
  const sampleRequest = await Request.create({
    requesterUser: createdUsers[3]._id, // Julian Vance
    requesterInstitution: createdInstitutions[3]._id,
    equipment: createdEquipment[0]._id, // Olympus Microscope
    listingOwner: createdUsers[0]._id, // Dr. Elena Rostova
    requestType: 'rental',
    requestedQuantity: 1,
    rentalStartDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
    rentalEndDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    intendedUse: 'High-resolution confocal imaging of synaptic spine dynamics in neurodevelopmental organoid models.',
    message: 'Hello Dr. Rostova, we would like to schedule access for 4 consecutive days to conduct our time-lapse series.',
    status: 'pending',
  });

  console.log('[Seed] Creating sample Notification...');
  await Notification.create({
    recipientUser: createdUsers[0]._id,
    eventType: 'request_created',
    title: 'New Rental Request: Olympus IX83',
    message: 'Julian Vance from Salk Institute for Biological Studies submitted a rental request.',
    relatedRequest: sampleRequest._id,
    relatedEquipment: createdEquipment[0]._id,
    isRead: false,
  });

  console.log(`[Seed] Successfully seeded:`);
  console.log(`  - ${createdInstitutions.length} Institutions`);
  console.log(`  - ${createdUsers.length} Users`);
  console.log(`  - ${createdEquipment.length} Equipment listings`);
  console.log(`  - 1 Sample request & notification`);
  console.log('[Seed] Sample credentials:');
  console.log('    Email: erostova@stanford.edu   Password: Password123!');
  console.log('    Email: mchen@mit.edu           Password: Password123!');
  console.log('    Email: salmansoor@berkeley.edu Password: Password123!');
  console.log('    Email: jvance@salk.edu         Password: Password123!');
  return { createdInstitutions, createdUsers, createdEquipment, sampleRequest };
};

export const seedDatabase = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/lablend';
  try {
    console.log('[Seed] Connecting to MongoDB...');
    await mongoose.connect(uri);
    await populateData();
    await mongoose.connection.close();
    console.log('[Seed] Database disconnected.');
  } catch (error) {
    console.error('[Seed Error] Failed to seed database:', error);
    process.exit(1);
  }
};

// Execute if run directly
if (process.argv[1]?.endsWith('seed.js')) {
  seedDatabase();
}

