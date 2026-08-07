// The repository interface is the seam between the app and its backend.
//
// Every screen depends on [CareRepository], never on a data source directly.
// [MockRepository] serves canned data so the app runs with no backend. To go
// live, write a FirestoreRepository that implements the same interface and
// swap the provider in lib/state/providers.dart — no screen changes.

import 'dart:async';
import 'models.dart';

abstract interface class CareRepository {
  List<ServiceItem> servicesFor(Appliance a);
  List<ServiceItem> catalog();
  List<Issue> issuesFor(Appliance a);
  List<SavedAddress> addresses();
  List<PaymentMethod> paymentMethods();
  List<Booking> bookings({BookingStatus? status, bool completed = false});
  Technician get preferredTechnician;

  /// Simulated tracking feed. Emits an ETA (minutes) that counts down, so the
  /// tracking screen has something live to animate. Firestore version streams
  /// technicians/{id}/locations/live instead.
  Stream<int> etaStream(String bookingId);

  // --- Technician app ---
  TechStats techStats();
  JobRequest? incomingRequest();
  List<RouteStop> routeToday();
  JobDetail jobDetail(String jobId);
  List<InvoiceLine> closeInvoice(String jobId);

  // --- Admin console ---
  AdminOverview adminOverview();
  List<AdminBooking> adminBookings();
  List<AdminTeamMember> adminTeam();
  List<AdminStockItem> adminStock();

  /// Resolves what a signed-in phone number is allowed to see. Everyone not
  /// on the staff allowlist is a plain customer — see [MockRepository] for
  /// the demo numbers. A FirestoreRepository would look this up from a
  /// custom claim or a `staff/{uid}` document instead.
  UserRole roleForPhone(String? e164Phone);
}

class MockRepository implements CareRepository {
  static const _sandeep = Technician(
    id: 't_sandeep',
    name: 'Sandeep Pawar',
    initials: 'SP',
    rating: 4.94,
    jobsDone: 1860,
    years: 6,
    vehicle: 'MH15 CJ 8842',
  );

  @override
  Technician get preferredTechnician => _sandeep;

  @override
  List<ServiceItem> servicesFor(Appliance a) {
    if (a.comingSoon) return const [];
    switch (a) {
      case Appliance.chimney:
        return [
          ServiceItem(
              id: 'chimney_clean',
              appliance: a,
              title: 'Deep clean — filters, motor, duct',
              blurb:
                  'Degreasing bath for baffle filters, blower and oil collector · 90 min',
              pricePaise: 159900,
              durationMin: 90,
              mostBooked: true),
          ServiceItem(
              id: 'chimney_repair',
              appliance: a,
              title: 'Repair visit and diagnosis',
              blurb: 'Fee waived if you approve the repair quote · parts extra',
              pricePaise: 39900,
              durationMin: 45),
          ServiceItem(
              id: 'chimney_install',
              appliance: a,
              title: 'Installation with duct work',
              blurb: 'Wall or island mount, up to 6 ft of ducting included',
              pricePaise: 169900,
              durationMin: 120),
          ServiceItem(
              id: 'chimney_uninstall',
              appliance: a,
              title: 'Uninstall and shift',
              blurb: 'Safe removal, capping and packing for a move',
              pricePaise: 59900,
              durationMin: 60),
        ];
      case Appliance.hob:
        return [
          ServiceItem(
              id: 'hob_clean',
              appliance: a,
              title: 'Deep clean — burners, valves, igniters',
              blurb:
                  'Ultrasonic bath for burner caps, igniter contacts tested · 60 min',
              pricePaise: 79900,
              durationMin: 60,
              mostBooked: true),
          ServiceItem(
              id: 'hob_repair',
              appliance: a,
              title: 'Repair visit and diagnosis',
              blurb: 'Fee waived if you approve the repair quote · parts extra',
              pricePaise: 39900,
              durationMin: 45),
          ServiceItem(
              id: 'hob_install',
              appliance: a,
              title: 'Installation with gas line check',
              blurb: 'Countertop or built-in mount, leak-tested on every joint',
              pricePaise: 69900,
              durationMin: 75),
          ServiceItem(
              id: 'hob_uninstall',
              appliance: a,
              title: 'Uninstall and cap the line',
              blurb: 'Safe gas disconnection and capping for a move',
              pricePaise: 39900,
              durationMin: 45),
        ];
      case Appliance.cooktop:
        return [
          ServiceItem(
              id: 'cooktop_clean',
              appliance: a,
              title: 'Deep clean and calibration',
              blurb:
                  'Glass surface polish, sensor and touch panel check · 50 min',
              pricePaise: 49900,
              durationMin: 50,
              mostBooked: true),
          ServiceItem(
              id: 'cooktop_repair',
              appliance: a,
              title: 'Repair visit and diagnosis',
              blurb: 'Fee waived if you approve the repair quote · parts extra',
              pricePaise: 39900,
              durationMin: 45),
          ServiceItem(
              id: 'cooktop_install',
              appliance: a,
              title: 'Installation and panel fitting',
              blurb: 'Countertop cutout fitting and power point check',
              pricePaise: 39900,
              durationMin: 60),
          ServiceItem(
              id: 'cooktop_uninstall',
              appliance: a,
              title: 'Uninstall and pack for a move',
              blurb: 'Safe removal and packing, glass surface protected',
              pricePaise: 29900,
              durationMin: 40),
        ];
      case Appliance.dishwasher:
        return [
          ServiceItem(
              id: 'dishwasher_clean',
              appliance: a,
              title: 'Deep clean — filter, spray arms, seals',
              blurb:
                  'Filter basket, spray arms and door seals descaled · 75 min',
              pricePaise: 119900,
              durationMin: 75,
              mostBooked: true),
          ServiceItem(
              id: 'dishwasher_repair',
              appliance: a,
              title: 'Repair visit and diagnosis',
              blurb: 'Fee waived if you approve the repair quote · parts extra',
              pricePaise: 59900,
              durationMin: 45),
          ServiceItem(
              id: 'dishwasher_install',
              appliance: a,
              title: 'Installation and plumbing connection',
              blurb: 'Water inlet, drain hose and levelling included',
              pricePaise: 149900,
              durationMin: 90),
          ServiceItem(
              id: 'dishwasher_uninstall',
              appliance: a,
              title: 'Uninstall and cap the lines',
              blurb: 'Safe disconnection and capping for a move',
              pricePaise: 59900,
              durationMin: 45),
        ];
      case Appliance.microwave:
        return [
          ServiceItem(
              id: 'microwave_clean',
              appliance: a,
              title: 'Deep clean and safety check',
              blurb: 'Interior degrease, door switch and leakage test · 45 min',
              pricePaise: 54900,
              durationMin: 45,
              mostBooked: true),
          ServiceItem(
              id: 'microwave_repair',
              appliance: a,
              title: 'Repair visit and diagnosis',
              blurb: 'Fee waived if you approve the repair quote · parts extra',
              pricePaise: 39900,
              durationMin: 45),
          ServiceItem(
              id: 'microwave_install',
              appliance: a,
              title: 'Built-in installation and trim kit',
              blurb: 'Cabinet mount, trim kit and vent check',
              pricePaise: 99900,
              durationMin: 90),
          ServiceItem(
              id: 'microwave_uninstall',
              appliance: a,
              title: 'Uninstall and cap the housing',
              blurb: 'Safe removal and packing for a move',
              pricePaise: 59900,
              durationMin: 45),
        ];
      case Appliance.otg:
        return [
          ServiceItem(
              id: 'otg_clean',
              appliance: a,
              title: 'Deep clean and element check',
              blurb:
                  'Interior degrease and heating element inspection · 40 min',
              pricePaise: 54900,
              durationMin: 40,
              mostBooked: true),
          ServiceItem(
              id: 'otg_repair',
              appliance: a,
              title: 'Repair visit and diagnosis',
              blurb: 'Fee waived if you approve the repair quote · parts extra',
              pricePaise: 39900,
              durationMin: 45),
          ServiceItem(
              id: 'otg_install',
              appliance: a,
              title: 'Installation and test bake',
              blurb: 'Placement, wiring check and a verified test bake',
              pricePaise: 99900,
              durationMin: 60),
          ServiceItem(
              id: 'otg_uninstall',
              appliance: a,
              title: 'Uninstall and pack for a move',
              blurb: 'Safe removal and packing for a move',
              pricePaise: 59900,
              durationMin: 40),
        ];
      case Appliance.refrigerator:
      case Appliance.purifier:
        return const []; // comingSoon — unreachable, guarded above
    }
  }

  @override
  List<ServiceItem> catalog() => [
        for (final a in Appliance.values.where((a) => !a.comingSoon))
          servicesFor(a).first,
      ];

  @override
  List<Issue> issuesFor(Appliance a) {
    switch (a) {
      case Appliance.chimney:
        return const [
          Issue('Weak or no suction', 'Most common on 2+ year old units',
              selected: true),
          Issue('Oil dripping from the hood', 'Collector or filter saturation',
              selected: true),
          Issue('Loud or rattling motor', 'Blower imbalance or loose mount',
              selected: true),
          Issue('Auto-clean not working', 'Heating coil or timer fault'),
          Issue('Lights not turning on', 'LED or switch failure'),
          Issue('Not switching on at all', 'Power, PCB or capacitor'),
        ];
      case Appliance.hob:
        return const [
          Issue('Igniter not sparking', 'Most common on 2+ year old units',
              selected: true),
          Issue('Flame is weak or uneven', 'Burner clogged or valve issue',
              selected: true),
          Issue('Gas smell near the knob', 'Valve seal or connection fault',
              selected: true),
          Issue("Burner won't light at all", 'Igniter or gas supply issue'),
          Issue('Knob is loose or stuck', 'Valve mechanism worn'),
          Issue('Auto-ignition clicking non-stop', 'Igniter switch fault'),
        ];
      case Appliance.cooktop:
        return const [
          Issue('Not heating at all', 'Power or induction coil fault',
              selected: true),
          Issue('Error code on display', 'Sensor or control board issue',
              selected: true),
          Issue('Touch panel not responding', 'Panel calibration or moisture',
              selected: true),
          Issue('Cracked or scratched glass', 'Surface damage'),
          Issue('Overheating or shuts off', 'Ventilation or sensor fault'),
          Issue('Uneven heating', 'Coil or zone fault'),
        ];
      case Appliance.dishwasher:
        return const [
          Issue('Not draining properly', 'Pump or filter blockage',
              selected: true),
          Issue('Dishes not coming out clean', 'Spray arm or filter clog',
              selected: true),
          Issue('Error code on display', 'Sensor or control fault',
              selected: true),
          Issue('Leaking from the door', 'Seal or gasket worn'),
          Issue('Making loud noise during cycle', 'Pump or motor issue'),
          Issue('Not starting at all', 'Power or door latch fault'),
        ];
      case Appliance.microwave:
        return const [
          Issue('Not heating food', 'Magnetron fault', selected: true),
          Issue('Turntable not spinning', 'Motor or roller worn',
              selected: true),
          Issue('Sparking inside', 'Metal object or panel damage',
              selected: true),
          Issue('Door not closing properly', 'Hinge or switch fault'),
          Issue('Display or buttons not working', 'Control panel fault'),
          Issue('Unusual smell or noise', 'Component wear'),
        ];
      case Appliance.otg:
        return const [
          Issue('Not heating properly', 'Element or thermostat fault',
              selected: true),
          Issue('Uneven baking', 'Heating element issue', selected: true),
          Issue('Timer not working', 'Timer mechanism fault', selected: true),
          Issue('Door glass loose or cracked', 'Hinge or glass damage'),
          Issue('Knobs stiff or not turning', 'Mechanism worn'),
          Issue('Not switching on at all', 'Power or wiring fault'),
        ];
      case Appliance.refrigerator:
      case Appliance.purifier:
        return const []; // comingSoon — unreachable, guarded in UI
    }
  }

  @override
  List<SavedAddress> addresses() => const [
        SavedAddress('a_home', 'Home',
            'B-704, Ashwin Residency, Gangapur Rd, Nashik 422013', '🏠'),
        SavedAddress('a_parents', 'Parents',
            '12, Shivneri Colony, College Rd, Nashik 422005', '🏢'),
      ];

  @override
  List<PaymentMethod> paymentMethods() => const [
        PaymentMethod(
            'upi', 'UPI — GPay, PhonePe, Paytm', 'Instant · no fee', '▲'),
        PaymentMethod('card', 'HDFC •••• 4471', 'Visa credit', '▭'),
        PaymentMethod('wallet', 'Rasoi Care wallet', '₹1,240 available', '◍'),
        PaymentMethod('netbank', 'Net banking', '12 banks', '▤'),
        PaymentMethod(
            'cod', 'Pay after the visit', 'Cash or UPI to technician', '₹'),
      ];

  @override
  List<Booking> bookings({BookingStatus? status, bool completed = false}) {
    final all = <Booking>[
      Booking(
        id: 'CP-2481-NSK',
        title: 'Chimney deep clean',
        appliance: Appliance.chimney,
        status: BookingStatus.onTheWay,
        whenLabel: 'Today · 10:00–11:00 am · Home',
        addressLabel: 'Home',
        totalPaise: 80000,
        technician: _sandeep,
      ),
      const Booking(
        id: 'CP-2496-NSK',
        title: 'Cooktop deep clean',
        appliance: Appliance.cooktop,
        status: BookingStatus.scheduled,
        whenLabel: '02 Aug · 4:00–6:00 pm · Parents',
        addressLabel: 'Parents',
        totalPaise: 49900,
      ),
      const Booking(
        id: 'CP-2109-NSK',
        title: 'Dishwasher — drain pump',
        appliance: Appliance.dishwasher,
        status: BookingStatus.completed,
        whenLabel: '12 Jun · Home',
        addressLabel: 'Home',
        totalPaise: 324000,
        stars: 5,
      ),
      const Booking(
        id: 'CP-1884-NSK',
        title: 'Chimney deep clean',
        appliance: Appliance.chimney,
        status: BookingStatus.completed,
        whenLabel: '12 Feb · Home',
        addressLabel: 'Home',
        totalPaise: 89900,
        stars: 5,
      ),
    ];
    if (completed) {
      return all.where((b) => b.status == BookingStatus.completed).toList();
    }
    return all
        .where((b) => b.status != BookingStatus.completed)
        .where((b) => status == null || b.status == status)
        .toList();
  }

  @override
  Stream<int> etaStream(String bookingId) async* {
    var eta = 14;
    yield eta;
    while (eta > 0) {
      await Future<void>.delayed(const Duration(seconds: 4));
      eta -= 1;
      yield eta;
    }
  }

  // --- Technician app ---
  @override
  TechStats techStats() => const TechStats(
        earningsTodayPaise: 318000,
        jobsDone: 4,
        jobsTotal: 6,
        tipsPaise: 42000,
        rating: 4.94,
        firstTimeFixPct: 91,
        onDuty: true,
      );

  @override
  JobRequest? incomingRequest() => const JobRequest(
        jobId: 'CP-2481',
        serviceTitle: 'Chimney · deep clean',
        distanceKm: 2.4,
        timeWindow: '10:00–11:00 am',
        payoutPaise: 64000,
        note: '2 filters flagged',
      );

  @override
  List<RouteStop> routeToday() => const [
        RouteStop(
          jobId: 'CP-2481',
          time: '10:00 am',
          title: 'Chimney deep clean',
          customerName: 'R. Deshpande',
          meta: 'B-704 Ashwin Residency · start code needed',
          status: StopStatus.inProgress,
        ),
        RouteStop(
          jobId: 'CP-2483',
          time: '12:30 pm',
          title: 'Hob — igniter fault',
          customerName: 'M. Kulkarni',
          meta: 'College Road · 3.1 km from previous',
          status: StopStatus.next,
        ),
        RouteStop(
          jobId: 'CP-2488',
          time: '3:00 pm',
          title: 'Cooktop deep clean',
          customerName: 'A. Sharma',
          meta: 'Indira Nagar · parts in van ✓',
          status: StopStatus.next,
        ),
      ];

  @override
  JobDetail jobDetail(String jobId) => JobDetail(
        jobId: jobId,
        customerName: 'Rohan Deshpande',
        customerInitials: 'RD',
        addressLine: 'B-704, Ashwin Residency, Gangapur Rd',
        directions: 'Gate code 4402, lift on the left',
        reportedTags: const ['Weak suction', 'Rattling noise', 'Oil dripping'],
        reportedQuote:
            'Smoke lingers even on turbo, and there\'s a rattle when it starts.',
        checklist: const [
          ChecklistItem('Start code verified', checked: true),
          ChecklistItem('Floor sheeting laid', checked: true),
          ChecklistItem('Suction reading before — 480 m³/hr', checked: true),
          ChecklistItem('Filters and blower degreased', checked: true),
          ChecklistItem('Suction reading after'),
          ChecklistItem('Site cleaned, customer walkthrough'),
        ],
        parts: const [
          PartLine(
            name: 'Baffle filter — Elica 90cm',
            sku: 'ELF-90B',
            qty: 2,
            pricePaise: 64000,
            approved: true,
            approvedAt: '11:02',
          ),
        ],
      );

  @override
  List<InvoiceLine> closeInvoice(String jobId) => const [
        InvoiceLine('Deep clean (prepaid)', 89900),
        InvoiceLine('Baffle filter set (2)', 64000),
        InvoiceLine('Visit and safety kit', 4900),
        InvoiceLine('CARE30', -27000, tone: LineTone.success),
        InvoiceLine('GST 18%', 23700),
      ];

  // --- Admin console ---
  @override
  AdminOverview adminOverview() => const AdminOverview(
        revenuePaise: 48200000,
        revenueDeltaPct: 12.4,
        jobsClosed: 318,
        jobsClosedDeltaPct: 6.1,
        slaBreaches: 7,
        slaBreachesToday: 3,
        avgRating: 4.86,
        ratingCount: 1204,
        weekBars: [62, 78, 54, 88, 96, 71, 84],
        weekLabels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
        technicianUtilisationPct: 87,
        firstTimeFixPct: 91,
        attention: [
          AttentionItem(
              'CP-2502',
              'Unassigned · 22 min',
              'Microwave not heating · Indira Nagar · slot 2:00 pm',
              LineTone.neutral),
          AttentionItem(
              'CP-2377',
              'Complaint · rework',
              'Hob igniter failed again in 6 days · warranty claim',
              LineTone.neutral),
          AttentionItem('CP-2418', 'Refund pending · ₹1,299',
              'Cancelled after dispatch · 3 days old', LineTone.neutral),
        ],
      );

  @override
  List<AdminBooking> adminBookings() => const [
        AdminBooking(
          jobId: 'CP-2502',
          title: 'Microwave not heating',
          meta: 'Indira Nagar · 2:00 pm',
          statusLabel: 'Unassigned',
          category: BookingCategory.unassigned,
        ),
        AdminBooking(
          jobId: 'CP-2481',
          title: 'Chimney deep clean',
          meta: 'Gangapur Rd · Sandeep P.',
          statusLabel: 'In progress',
          category: BookingCategory.inProgress,
        ),
        AdminBooking(
          jobId: 'CP-2496',
          title: 'RO filter change',
          meta: 'College Rd · Nilesh K.',
          statusLabel: 'Scheduled',
          category: BookingCategory.scheduled,
        ),
        AdminBooking(
          jobId: 'CP-2477',
          title: 'Dishwasher install',
          meta: 'Ashok Nagar · Imran S.',
          statusLabel: 'Closed ₹3,240',
          category: BookingCategory.closed,
        ),
        AdminBooking(
          jobId: 'CP-2468',
          title: 'Hob igniter',
          meta: 'Panchavati · Sandeep P.',
          statusLabel: 'Closed ₹1,180',
          category: BookingCategory.closed,
        ),
      ];

  @override
  List<AdminTeamMember> adminTeam() => const [
        AdminTeamMember(
          name: 'Sandeep Pawar',
          initials: 'SP',
          specialties: 'Chimney, hob',
          statsLabel: '6 jobs · ₹3,180',
          rating: 4.94,
          duty: DutyStatus.onJob,
        ),
        AdminTeamMember(
          name: 'Nilesh Kadam',
          initials: 'NK',
          specialties: 'Microwave, OTG',
          statsLabel: '5 jobs · ₹2,410',
          rating: 4.88,
          duty: DutyStatus.idle,
        ),
        AdminTeamMember(
          name: 'Imran Shaikh',
          initials: 'IS',
          specialties: 'Dishwasher, fridge',
          statsLabel: '7 jobs · ₹4,020',
          rating: 4.91,
          duty: DutyStatus.onJob,
        ),
        AdminTeamMember(
          name: 'Ravi Bhoir',
          initials: 'RB',
          specialties: 'Microwave, cooktop',
          statsLabel: '4 jobs · ₹1,960',
          rating: 4.72,
          duty: DutyStatus.offDuty,
        ),
      ];

  @override
  List<AdminStockItem> adminStock() => const [
        AdminStockItem(
            name: 'Elica baffle filter 90cm',
            sku: 'ELF-90B',
            inStock: 8,
            reorderAt: 40,
            low: true),
        AdminStockItem(
            name: 'RO membrane 80 GPD',
            sku: 'ROM-80',
            inStock: 14,
            reorderAt: 40,
            low: true),
        AdminStockItem(
            name: 'Hob igniter — universal',
            sku: 'HBI-U',
            inStock: 9,
            reorderAt: 30,
            low: true),
        AdminStockItem(
            name: 'Dishwasher drain pump',
            sku: 'DWP-BSH',
            inStock: 26,
            reorderAt: 30,
            low: false),
        AdminStockItem(
            name: 'Fridge gas R600a (can)',
            sku: 'GAS-600',
            inStock: 48,
            reorderAt: 30,
            low: false),
      ];

  // Demo staff allowlist — stand-in for a real backend's custom claims.
  // Any other signed-in number is a plain customer.
  static const _staffRoles = <String, UserRole>{
    '+919000000001': UserRole.admin,
    '+919000000002': UserRole.technician,
  };

  @override
  UserRole roleForPhone(String? e164Phone) =>
      _staffRoles[e164Phone] ?? UserRole.customer;
}
