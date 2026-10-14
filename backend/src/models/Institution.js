import mongoose from 'mongoose';

const institutionSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Institution name is required'],
      trim: true,
      maxlength: [150, 'Institution name cannot exceed 150 characters'],
    },
    type: {
      type: String,
      required: [true, 'Institution type is required'],
      enum: ['university', 'college', 'research_institute', 'hospital', 'commercial_lab', 'other'],
      default: 'university',
    },
    description: {
      type: String,
      trim: true,
      maxlength: [1000, 'Description cannot exceed 1000 characters'],
      default: '',
    },
    address: {
      type: String,
      trim: true,
      default: '',
    },
    city: {
      type: String,
      required: [true, 'City is required'],
      trim: true,
    },
    state: {
      type: String,
      required: [true, 'State or province is required'],
      trim: true,
    },
    postalCode: {
      type: String,
      trim: true,
      default: '',
    },
    country: {
      type: String,
      trim: true,
      default: 'United States',
    },
    contactEmail: {
      type: String,
      trim: true,
      lowercase: true,
      match: [/\S+@\S+\.\S+/, 'Please provide a valid email address'],
    },
    contactNumber: {
      type: String,
      trim: true,
      default: '',
    },
    verificationStatus: {
      type: String,
      enum: ['verified', 'pending', 'unverified'],
      default: 'unverified',
    },
    verificationMetadata: {
      verifiedAt: { type: Date },
      verifiedBy: { type: String },
      verificationNotes: { type: String },
    },
  },
  {
    timestamps: true,
  }
);

institutionSchema.index({ name: 'text', city: 'text', state: 'text' });

const Institution = mongoose.model('Institution', institutionSchema);
export default Institution;
