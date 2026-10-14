import mongoose from 'mongoose';

const imageSchema = new mongoose.Schema(
  {
    url: {
      type: String,
      required: true,
    },
    publicId: {
      type: String,
      required: true,
    },
    isCover: {
      type: Boolean,
      default: false,
    },
  },
  { _id: false }
);

const technicalSpecSchema = new mongoose.Schema(
  {
    key: {
      type: String,
      required: true,
      trim: true,
    },
    value: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { _id: false }
);

const equipmentSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Equipment title is required'],
      trim: true,
      maxlength: [180, 'Title cannot exceed 180 characters'],
    },
    slug: {
      type: String,
      lowercase: true,
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Equipment description is required'],
      trim: true,
      maxlength: [4000, 'Description cannot exceed 4000 characters'],
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: [
        'microscopy',
        'spectroscopy',
        'centrifugation',
        'chromatography',
        'thermal_analysis',
        'electronics',
        'cell_culture',
        'analytical_chemistry',
        'general_lab',
      ],
      index: true,
    },
    condition: {
      type: String,
      required: [true, 'Condition is required'],
      enum: ['like_new', 'excellent', 'good', 'fair'],
      default: 'excellent',
    },
    technicalSpecs: [technicalSpecSchema],
    images: {
      type: [imageSchema],
      validate: {
        validator: function (val) {
          return val && val.length > 0;
        },
        message: 'At least one equipment image is required',
      },
    },
    listingType: {
      type: String,
      required: [true, 'Listing type is required'],
      enum: ['rent', 'buy', 'both'],
      default: 'rent',
      index: true,
    },
    rentalPrice: {
      type: Number,
      min: [0, 'Rental price cannot be negative'],
      default: null,
    },
    rentalPricingUnit: {
      type: String,
      enum: ['hour', 'day', 'week', 'month'],
      default: 'day',
    },
    purchasePrice: {
      type: Number,
      min: [0, 'Purchase price cannot be negative'],
      default: null,
    },
    availability: {
      type: String,
      enum: ['available', 'rented', 'maintenance', 'reserved'],
      default: 'available',
      index: true,
    },
    location: {
      building: { type: String, trim: true, default: '' },
      room: { type: String, trim: true, default: '' },
      city: { type: String, trim: true, required: true },
      state: { type: String, trim: true, required: true },
    },
    ownerUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    ownerInstitution: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Institution',
      required: true,
      index: true,
    },
    isArchived: {
      type: Boolean,
      default: false,
      index: true,
    },
    featured: {
      type: Boolean,
      default: false,
      index: true,
    },
    totalBookings: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Compound and text indexes for fast search & filtering
equipmentSchema.index({ title: 'text', description: 'text' });
equipmentSchema.index({ category: 1, availability: 1, listingType: 1 });
equipmentSchema.index({ rentalPrice: 1, purchasePrice: 1 });
equipmentSchema.index({ createdAt: -1 });

const Equipment = mongoose.model('Equipment', equipmentSchema);
export default Equipment;
