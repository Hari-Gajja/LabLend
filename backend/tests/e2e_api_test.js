import app from '../src/app.js';
import { connectDB, disconnectDB } from '../src/config/database.js';

let server;
const PORT = 5001;
const BASE_URL = `http://localhost:${PORT}/api/v1`;

const results = [];

function recordResult(name, passed, details = '') {
  results.push({ name, passed, details });
  const icon = passed ? '✅' : '❌';
  console.log(`${icon} [${name}] ${details}`);
}

async function runAllTests() {
  console.log('\n======================================================');
  console.log('🧪 Starting LabLend End-to-End API Test Suite');
  console.log('======================================================\n');

  try {
    await connectDB();
    server = app.listen(PORT, '0.0.0.0');
    console.log(`[Test Server] Running on ${BASE_URL}\n`);

    // 1. Health Check
    try {
      const res = await fetch(`${BASE_URL}/health`);
      const body = await res.json();
      recordResult('Health Check', res.status === 200 && body.data.status === 'healthy', `Status: ${res.status}`);
    } catch (err) {
      recordResult('Health Check', false, err.message);
    }

    // 2. Institutions List
    let institutions = [];
    try {
      const res = await fetch(`${BASE_URL}/institutions`);
      const body = await res.json();
      institutions = body.data?.institutions || [];
      recordResult('Get Institutions', res.status === 200 && institutions.length >= 4, `Found ${institutions.length} institutions`);
    } catch (err) {
      recordResult('Get Institutions', false, err.message);
    }

    // 3. User Login - Owner (Dr. Elena Rostova)
    let ownerToken = '';
    let ownerUser = null;
    try {
      const res = await fetch(`${BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'erostova@stanford.edu', password: 'Password123!' }),
      });
      const body = await res.json();
      ownerToken = body.data?.token;
      ownerUser = body.data?.user;
      recordResult('Auth Login (Owner)', res.status === 200 && !!ownerToken, `User: ${ownerUser?.fullName} (${ownerUser?.role})`);
    } catch (err) {
      recordResult('Auth Login (Owner)', false, err.message);
    }

    // 4. User Login - Requester (Julian Vance)
    let requesterToken = '';
    let requesterUser = null;
    try {
      const res = await fetch(`${BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'jvance@salk.edu', password: 'Password123!' }),
      });
      const body = await res.json();
      requesterToken = body.data?.token;
      requesterUser = body.data?.user;
      recordResult('Auth Login (Requester)', res.status === 200 && !!requesterToken, `User: ${requesterUser?.fullName} (${requesterUser?.role})`);
    } catch (err) {
      recordResult('Auth Login (Requester)', false, err.message);
    }

    // 5. Auth Failure Check (Invalid Credentials)
    try {
      const res = await fetch(`${BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'erostova@stanford.edu', password: 'WrongPassword999!' }),
      });
      recordResult('Auth Invalid Password Rejection', res.status === 401, `Status: ${res.status}`);
    } catch (err) {
      recordResult('Auth Invalid Password Rejection', false, err.message);
    }

    // 6. Auth Me endpoint
    try {
      const res = await fetch(`${BASE_URL}/auth/me`, {
        headers: { Authorization: `Bearer ${ownerToken}` },
      });
      const body = await res.json();
      recordResult('Auth Me Profile Verification', res.status === 200 && body.data?.user?.email === 'erostova@stanford.edu', `Email: ${body.data?.user?.email}`);
    } catch (err) {
      recordResult('Auth Me Profile Verification', false, err.message);
    }

    // 7. Get Equipment Listings (All)
    let equipmentList = [];
    try {
      const res = await fetch(`${BASE_URL}/equipment?limit=10`);
      const body = await res.json();
      equipmentList = body.data?.equipment || [];
      recordResult('Get Equipment Listings', res.status === 200 && equipmentList.length > 0, `Count: ${equipmentList.length}`);
    } catch (err) {
      recordResult('Get Equipment Listings', false, err.message);
    }

    // 8. Filter Equipment by Category (microscopy)
    try {
      const res = await fetch(`${BASE_URL}/equipment?category=microscopy`);
      const body = await res.json();
      const list = body.data?.equipment || [];
      const allMicro = list.length > 0 && list.every(e => e.category === 'microscopy');
      recordResult('Filter Equipment by Category', res.status === 200 && allMicro, `Found: ${list.length} microscopy items`);
    } catch (err) {
      recordResult('Filter Equipment by Category', false, err.message);
    }

    // 9. Search Equipment by Query ("centrifuge")
    try {
      const res = await fetch(`${BASE_URL}/equipment?search=centrifuge`);
      const body = await res.json();
      const list = body.data?.equipment || [];
      recordResult('Search Equipment by Query', res.status === 200 && list.length > 0, `Search returned: ${list[0]?.title}`);
    } catch (err) {
      recordResult('Search Equipment by Query', false, err.message);
    }

    // 10. Get Equipment by ID
    let targetEquipment = equipmentList[0];
    try {
      const res = await fetch(`${BASE_URL}/equipment/${targetEquipment._id}`);
      const body = await res.json();
      const item = body.data?.equipment;
      recordResult('Get Equipment By ID', res.status === 200 && item?._id === targetEquipment._id, `Item: ${item?.title}`);
    } catch (err) {
      recordResult('Get Equipment By ID', false, err.message);
    }

    // 11. Create New Equipment Listing
    let newlyCreatedEquipmentId = null;
    try {
      const payload = {
        title: 'Illumina NextSeq 2000 Sequencing System',
        description: 'High-throughput benchtop sequencer designed for single-cell RNA-seq, exome sequencing, and spatial transcriptomics analysis.',
        category: 'spectroscopy',
        condition: 'like_new',
        listingType: 'both',
        rentalPrice: 500,
        rentalPricingUnit: 'day',
        purchasePrice: 125000,
        location: {
          building: 'Shriram Bio Center',
          room: 'G-301',
          city: 'Stanford',
          state: 'CA',
        },
        technicalSpecs: [
          { key: 'Flow Cell Types', value: 'P1, P2, P3' },
          { key: 'Output', value: 'Up to 360 Gb and 1.2B reads' },
        ],
        images: [
          {
            url: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?q=80&w=1200&auto=format&fit=crop',
            publicId: 'nextseq_2000',
            isCover: true,
          },
        ],
      };
      const res = await fetch(`${BASE_URL}/equipment`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${ownerToken}`,
        },
        body: JSON.stringify(payload),
      });
      const body = await res.json();
      newlyCreatedEquipmentId = body.data?.equipment?._id;
      recordResult('Create Equipment Listing', res.status === 201 && !!newlyCreatedEquipmentId, `Created ID: ${newlyCreatedEquipmentId}`);
    } catch (err) {
      recordResult('Create Equipment Listing', false, err.message);
    }

    // 12. Get Owner's My Listings
    try {
      const res = await fetch(`${BASE_URL}/equipment/mine`, {
        headers: { Authorization: `Bearer ${ownerToken}` },
      });
      const body = await res.json();
      const myList = body.data?.equipment || [];
      const hasCreated = myList.some(e => e._id === newlyCreatedEquipmentId);
      recordResult('Get My Equipment Listings', res.status === 200 && hasCreated, `Total owned: ${myList.length}`);
    } catch (err) {
      recordResult('Get My Equipment Listings', false, err.message);
    }

    // 13. Submit Rental Request (Julian requests Elena's new equipment)
    let newRequestId = null;
    const startDate = new Date(Date.now() + 10 * 24 * 60 * 60 * 1000).toISOString();
    const endDate = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString();
    try {
      const payload = {
        equipmentId: newlyCreatedEquipmentId,
        requestType: 'rental',
        requestedQuantity: 1,
        rentalStartDate: startDate,
        rentalEndDate: endDate,
        intendedUse: 'Single-cell profiling of neurodegenerative organoids under stress condition.',
        message: 'Requesting access for sequencing run batch 4B.',
      };
      const res = await fetch(`${BASE_URL}/requests`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${requesterToken}`,
        },
        body: JSON.stringify(payload),
      });
      const body = await res.json();
      newRequestId = body.data?.request?._id;
      recordResult('Submit Rental Request', res.status === 201 && !!newRequestId, `Request ID: ${newRequestId}`);
    } catch (err) {
      recordResult('Submit Rental Request', false, err.message);
    }

    // 14. Get Sent Requests (Requester)
    try {
      const res = await fetch(`${BASE_URL}/requests/sent`, {
        headers: { Authorization: `Bearer ${requesterToken}` },
      });
      const body = await res.json();
      const sent = body.data?.requests || [];
      recordResult('Get Sent Requests', res.status === 200 && sent.some(r => r._id === newRequestId), `Sent count: ${sent.length}`);
    } catch (err) {
      recordResult('Get Sent Requests', false, err.message);
    }

    // 15. Get Received Requests (Owner)
    try {
      const res = await fetch(`${BASE_URL}/requests/received`, {
        headers: { Authorization: `Bearer ${ownerToken}` },
      });
      const body = await res.json();
      const rec = body.data?.requests || [];
      recordResult('Get Received Requests', res.status === 200 && rec.some(r => r._id === newRequestId), `Received count: ${rec.length}`);
    } catch (err) {
      recordResult('Get Received Requests', false, err.message);
    }

    // 16. Approve Booking Request (Owner Elena approves Julian's request)
    try {
      const res = await fetch(`${BASE_URL}/requests/${newRequestId}/approve`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${ownerToken}`,
        },
        body: JSON.stringify({
          notes: 'Access approved. Please coordinate with lab technician for orientation.',
        }),
      });
      const body = await res.json();
      const reqStatus = body.data?.request?.status;
      recordResult('Approve Booking Request', res.status === 200 && reqStatus === 'approved', `New status: ${reqStatus}`);
    } catch (err) {
      recordResult('Approve Booking Request', false, err.message);
    }

    // 17. Overlapping Schedule Conflict Check (Attempt booking overlapping dates on approved equipment)
    try {
      const conflictStart = new Date(Date.now() + 11 * 24 * 60 * 60 * 1000).toISOString();
      const conflictEnd = new Date(Date.now() + 13 * 24 * 60 * 60 * 1000).toISOString();
      const res = await fetch(`${BASE_URL}/requests`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${requesterToken}`,
        },
        body: JSON.stringify({
          equipmentId: newlyCreatedEquipmentId,
          requestType: 'rental',
          rentalStartDate: conflictStart,
          rentalEndDate: conflictEnd,
          intendedUse: 'Overlapping reservation conflict verification test.',
        }),
      });
      const body = await res.json();
      recordResult('Overlapping Booking Conflict Rejection', res.status === 409, `Expected 409 Conflict: Got ${res.status} (${body.message})`);
    } catch (err) {
      recordResult('Overlapping Booking Conflict Rejection', false, err.message);
    }

    // 18. Cloudinary Upload Signature Endpoint
    try {
      const res = await fetch(`${BASE_URL}/uploads/signature`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${ownerToken}`,
        },
        body: JSON.stringify({ folder: 'lablend/equipment' }),
      });
      const body = await res.json();
      recordResult('Cloudinary Signed Upload Endpoint', res.status === 200 && !!body.data?.signature, `Cloud: ${body.data?.cloudName}, API Key: ${body.data?.apiKey}`);
    } catch (err) {
      recordResult('Cloudinary Signed Upload Endpoint', false, err.message);
    }

    // 19. Get Notifications
    let notificationId = null;
    try {
      const res = await fetch(`${BASE_URL}/notifications`, {
        headers: { Authorization: `Bearer ${ownerToken}` },
      });
      const body = await res.json();
      const notifs = body.data?.notifications || [];
      notificationId = notifs[0]?._id;
      recordResult('Get User Notifications', res.status === 200 && notifs.length > 0, `Notifications: ${notifs.length}`);
    } catch (err) {
      recordResult('Get User Notifications', false, err.message);
    }

    // 20. Mark Notification as Read
    if (notificationId) {
      try {
        const res = await fetch(`${BASE_URL}/notifications/${notificationId}/read`, {
          method: 'PATCH',
          headers: { Authorization: `Bearer ${ownerToken}` },
        });
        const body = await res.json();
        const isRead = body.data?.notification?.isRead;
        recordResult('Mark Notification As Read', res.status === 200 && isRead === true, `Marked read: ${isRead}`);
      } catch (err) {
        recordResult('Mark Notification As Read', false, err.message);
      }
    }

  } catch (globalErr) {
    console.error('Fatal test error:', globalErr);
  } finally {
    if (server) {
      server.close();
      console.log('\n[Test Server] Closed.');
    }
    await disconnectDB();
  }

  // Summary
  const passedCount = results.filter(r => r.passed).length;
  const totalCount = results.length;
  console.log('\n======================================================');
  console.log(`📊 Test Results: ${passedCount}/${totalCount} Passed (${Math.round((passedCount/totalCount)*100)}%)`);
  console.log('======================================================\n');

  if (passedCount === totalCount) {
    console.log('🎉 ALL 20 ENDPOINTS VERIFIED & WORKING PERFECTLY!\n');
    process.exit(0);
  } else {
    console.error('⚠️ Some tests failed.');
    process.exit(1);
  }
}

runAllTests();
