import mongoose from 'mongoose';

const requestSchema = new mongoose.Schema(
  {
    requesterUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    requesterInstitution: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Institution',
      required: true,
      index: true,
    },
    equipment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Equipment',
      required: true,
      index: true,
    },
    listingOwner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    requestType: {
      type: String,
      required: true,
      enum: ['rental', 'purchase'],
    },
    status: {
      type: String,
      required: true,
      enum: ['pending', 'approved', 'rejected', 'cancelled', 'completed'],
      default: 'pending',
      index: true,
    },
    requestedQuantity: {
      type: Number,
      required: true,
      min: 1,
      default: 1,
    },
    rentalStartDate: {
      type: Date,
      default: null,
    },
    rentalEndDate: {
      type: Date,
      default: null,
    },
    intendedUse: {
      type: String,
      required: [true, 'Intended use description is required'],
      trim: true,
      maxlength: [1500, 'Intended use cannot exceed 1500 characters'],
    },
    message: {
      type: String,
      trim: true,
      maxlength: [2000, 'Message cannot exceed 2000 characters'],
      default: '',
    },
    decisionMetadata: {
      decidedAt: { type: Date, default: null },
      decidedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
      reason: { type: String, default: '' },
      notes: { type: String, default: '' },
    },
    cancellationMetadata: {
      cancelledAt: { type: Date, default: null },
      cancelledBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
      reason: { type: String, default: '' },
    },
    completionMetadata: {
      completedAt: { type: Date, default: null },
      notes: { type: String, default: '' },
    },
  },
  {
    timestamps: true,
  }
);

requestSchema.index({ equipment: 1, status: 1, rentalStartDate: 1, rentalEndDate: 1 });
requestSchema.index({ requesterUser: 1, createdAt: -1 });
requestSchema.index({ listingOwner: 1, createdAt: -1 });

const Request = mongoose.model('Request', requestSchema);
export default Request;
