import '../utils/enums.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/proposals/domain/entities/proposal.dart';
import '../../features/freelancer_dashboard/domain/entities/freelancer.dart';
import '../../features/client_dashboard/domain/entities/company.dart';
import '../../features/startup_ideas/domain/entities/startup.dart';
import '../../features/investor_dashboard/domain/entities/investor.dart';
import '../../features/founder_dashboard/domain/entities/founder.dart';
import '../../features/messages/domain/entities/conversation.dart';
import '../../features/meetings/domain/entities/meeting.dart';
import '../../features/wallet/domain/entities/wallet.dart';
import '../../features/subscriptions/domain/entities/subscription_plan.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/profile/domain/entities/review.dart';
import '../../features/catalog/domain/entities/catalog_entities.dart';

/// Central in-memory mock database.
///
/// This is the single source of truth for all mock content. Feature
/// repositories read from here today and will be re-pointed to live
/// datasources later without touching the presentation layer.
class MockData {
  MockData._();

  static DateTime _daysAgo(int d) => DateTime.now().subtract(Duration(days: d));
  static DateTime _hoursAhead(int h) => DateTime.now().add(Duration(hours: h));

  static const _avatar = 'https://i.pravatar.cc/300';
  static String avatar(int seed) => '$_avatar?img=$seed';

  // ---- Current signed-in user (defaults; role set at role-selection) ----
  static AppUser currentUser = const AppUser(
    id: 'u_current',
    fullName: 'Aarav Sharma',
    email: 'aarav@goexperts.example',
    phone: '+91 98765 43210',
    avatarUrl: '$_avatar?img=12',
    isVerified: true,
    isProfileComplete: true,
    headline: 'Full-Stack Engineer',
    location: 'Bengaluru, India',
  );

  // ---- Freelancers ----
  static final List<Freelancer> freelancers = [
    Freelancer(
      id: 'f1', name: 'Priya Nair', headline: 'Senior Flutter & Dart Developer',
      category: 'Mobile Development',
      skills: const ['Flutter', 'Dart', 'Firebase', 'BLoC', 'REST APIs'],
      hourlyRate: 2200, rating: 4.9, reviewsCount: 128, location: 'Kochi, India',
      avatarUrl: avatar(5), experienceYears: 6, completedProjects: 94,
      bio: 'Building beautiful cross-platform apps for startups and enterprises.',
      followers: 1240, successRate: 98,
    ),
    Freelancer(
      id: 'f2', name: 'Rohan Mehta', headline: 'UI/UX Designer & Product Thinker',
      category: 'Design',
      skills: const ['Figma', 'Design Systems', 'Prototyping', 'Webflow'],
      hourlyRate: 1800, rating: 4.8, reviewsCount: 76, location: 'Mumbai, India',
      avatarUrl: avatar(11), experienceYears: 5, completedProjects: 61, followers: 890,
    ),
    Freelancer(
      id: 'f3', name: 'Sneha Reddy', headline: 'Backend Engineer · Node & Go',
      category: 'Web Development',
      skills: const ['Node.js', 'Go', 'PostgreSQL', 'AWS', 'Docker'],
      hourlyRate: 2500, rating: 4.7, reviewsCount: 54, location: 'Hyderabad, India',
      avatarUrl: avatar(20), experienceYears: 7, completedProjects: 43, followers: 640,
    ),
    Freelancer(
      id: 'f4', name: 'Karan Singh', headline: 'Data Scientist & ML Engineer',
      category: 'AI / ML',
      skills: const ['Python', 'TensorFlow', 'LLMs', 'Pandas', 'MLOps'],
      hourlyRate: 3200, rating: 5.0, reviewsCount: 39, location: 'Delhi, India',
      avatarUrl: avatar(33), experienceYears: 8, completedProjects: 30, followers: 2100,
    ),
    Freelancer(
      id: 'f5', name: 'Ananya Iyer', headline: 'Digital Marketing Strategist',
      category: 'Marketing',
      skills: const ['SEO', 'Google Ads', 'Content', 'Analytics'],
      hourlyRate: 1500, rating: 4.6, reviewsCount: 88, location: 'Pune, India',
      avatarUrl: avatar(45), experienceYears: 4, completedProjects: 72, followers: 510,
    ),
    Freelancer(
      id: 'f6', name: 'Vikram Patel', headline: 'DevOps & Cloud Architect',
      category: 'DevOps',
      skills: const ['Kubernetes', 'Terraform', 'AWS', 'CI/CD'],
      hourlyRate: 2800, rating: 4.9, reviewsCount: 47, location: 'Ahmedabad, India',
      avatarUrl: avatar(52), experienceYears: 9, completedProjects: 38, followers: 730,
    ),
  ];

  // ---- Projects ----
  static final List<Project> projects = [
    Project(
      id: 'p1', title: 'Build a Fintech Mobile App (Flutter)',
      description:
          'We need an experienced Flutter developer to build a secure fintech app with UPI payments, wallet, KYC and a clean dashboard. Clean architecture + BLoC preferred.',
      clientName: 'PayNova Technologies', category: 'Mobile Development',
      skills: const ['Flutter', 'BLoC', 'Payments', 'Firebase'],
      techStack: const ['Flutter', 'Dart', 'Node.js'],
      budgetMin: 250000, budgetMax: 450000, isHourly: false, timeline: '3 months',
      status: EntityStatus.open, postedAt: _daysAgo(1), proposalsCount: 12,
      clientAvatar: avatar(60), experienceLevel: 'Expert',
    ),
    Project(
      id: 'p2', title: 'E-commerce Website Revamp',
      description:
          'Redesign and rebuild our Shopify storefront with a modern, conversion-focused UI. Looking for design + front-end skills.',
      clientName: 'Urban Threads', category: 'Web Development',
      skills: const ['React', 'Shopify', 'UI/UX', 'Tailwind'],
      techStack: const ['React', 'Next.js'],
      budgetMin: 800, budgetMax: 1500, isHourly: true, timeline: '6 weeks',
      status: EntityStatus.open, postedAt: _daysAgo(2), proposalsCount: 8,
      clientAvatar: avatar(62), workMode: 'Remote',
    ),
    Project(
      id: 'p3', title: 'AI Chatbot for Customer Support',
      description:
          'Implement an LLM-powered support chatbot integrated with our helpdesk. RAG pipeline + analytics dashboard.',
      clientName: 'Helpline AI', category: 'AI / ML',
      skills: const ['Python', 'LLMs', 'LangChain', 'Vector DB'],
      techStack: const ['Python', 'FastAPI'],
      budgetMin: 400000, budgetMax: 700000, isHourly: false, timeline: '4 months',
      status: EntityStatus.open, postedAt: _daysAgo(3), proposalsCount: 21,
      clientAvatar: avatar(64), experienceLevel: 'Expert',
    ),
    Project(
      id: 'p4', title: 'Brand Identity & Logo Design',
      description: 'New brand identity for a D2C skincare startup — logo, palette, typography and guidelines.',
      clientName: 'Glow Naturals', category: 'Design',
      skills: const ['Branding', 'Illustrator', 'Figma'],
      budgetMin: 60000, budgetMax: 120000, isHourly: false, timeline: '3 weeks',
      status: EntityStatus.open, postedAt: _daysAgo(4), proposalsCount: 15,
      clientAvatar: avatar(65),
    ),
    Project(
      id: 'p5', title: 'DevOps: Migrate to Kubernetes',
      description: 'Containerize services and set up an EKS cluster with CI/CD, monitoring and autoscaling.',
      clientName: 'ScaleWorks', category: 'DevOps',
      skills: const ['Kubernetes', 'AWS', 'Terraform', 'CI/CD'],
      techStack: const ['AWS', 'Docker'],
      budgetMin: 1000, budgetMax: 2000, isHourly: true, timeline: '2 months',
      status: EntityStatus.active, postedAt: _daysAgo(6), proposalsCount: 5,
      clientAvatar: avatar(66), experienceLevel: 'Expert', isApplied: true,
    ),
    Project(
      id: 'p6', title: 'SEO & Content Marketing Retainer',
      description: 'Ongoing SEO, content strategy and monthly reporting for a SaaS company.',
      clientName: 'CloudDesk', category: 'Marketing',
      skills: const ['SEO', 'Content', 'Analytics'],
      budgetMin: 40000, budgetMax: 80000, isHourly: false, timeline: 'Ongoing',
      status: EntityStatus.open, postedAt: _daysAgo(7), proposalsCount: 9, clientAvatar: avatar(67),
    ),
  ];

  // ---- Proposals ----
  static final List<Proposal> proposals = [
    Proposal(
      id: 'pr1', projectTitle: 'Build a Fintech Mobile App (Flutter)',
      freelancerName: 'Priya Nair', bidAmount: 380000, isHourly: false,
      coverLetter:
          'I have shipped 3 fintech apps with UPI + KYC. I can deliver a production-ready app with clean architecture in 12 weeks.',
      status: EntityStatus.underReview, submittedAt: _daysAgo(1),
      freelancerAvatar: avatar(5), deliveryDays: 84, freelancerRating: 4.9,
    ),
    Proposal(
      id: 'pr2', projectTitle: 'E-commerce Website Revamp',
      freelancerName: 'Rohan Mehta', bidAmount: 1200, isHourly: true,
      coverLetter: 'Design-led front-end developer. Portfolio of 20+ storefronts. Available immediately.',
      status: EntityStatus.shortlisted, submittedAt: _daysAgo(2),
      freelancerAvatar: avatar(11), freelancerRating: 4.8,
    ),
    Proposal(
      id: 'pr3', projectTitle: 'AI Chatbot for Customer Support',
      freelancerName: 'Karan Singh', bidAmount: 620000, isHourly: false,
      coverLetter: 'ML engineer specialising in RAG + LLMs. Delivered similar bots at scale.',
      status: EntityStatus.pending, submittedAt: _daysAgo(1),
      freelancerAvatar: avatar(33), freelancerRating: 5.0,
    ),
    Proposal(
      id: 'pr4', projectTitle: 'Brand Identity & Logo Design',
      freelancerName: 'Rohan Mehta', bidAmount: 95000, isHourly: false,
      coverLetter: 'Award-winning brand designer. Includes 3 concepts + full guidelines.',
      status: EntityStatus.accepted, submittedAt: _daysAgo(5),
      freelancerAvatar: avatar(11), freelancerRating: 4.8,
    ),
  ];

  // ---- Contracts ----
  static final List<Contract> contracts = [
    Contract(
      id: 'c1', projectTitle: 'DevOps: Migrate to Kubernetes',
      counterpartyName: 'ScaleWorks', amount: 320000, status: EntityStatus.inProgress,
      startDate: _daysAgo(20), progress: 0.55, counterpartyAvatar: avatar(66),
      milestones: [
        Milestone(title: 'Containerization', amount: 100000, status: EntityStatus.completed, dueDate: _daysAgo(5)),
        Milestone(title: 'EKS setup', amount: 120000, status: EntityStatus.inProgress, dueDate: _hoursAhead(240)),
        Milestone(title: 'CI/CD & monitoring', amount: 100000, status: EntityStatus.pending, dueDate: _hoursAhead(600)),
      ],
    ),
    Contract(
      id: 'c2', projectTitle: 'Brand Identity & Logo Design',
      counterpartyName: 'Glow Naturals', amount: 95000, status: EntityStatus.completed,
      startDate: _daysAgo(60), progress: 1, counterpartyAvatar: avatar(65),
      milestones: [
        Milestone(title: 'Concepts', amount: 40000, status: EntityStatus.completed, dueDate: _daysAgo(45)),
        Milestone(title: 'Final delivery', amount: 55000, status: EntityStatus.completed, dueDate: _daysAgo(30)),
      ],
    ),
  ];

  // ---- Companies ----
  static final List<Company> companies = [
    Company(
      id: 'co1', name: 'PayNova Technologies', industry: 'FinTech',
      location: 'Bengaluru, India', ownerName: 'Meera Raghavan',
      description: 'Building the next-gen payments infrastructure for India.',
      website: 'https://paynova.example', teamSize: '51-200',
      projectsPosted: 18, hiresCount: 34, logoUrl: avatar(60),
    ),
    Company(
      id: 'co2', name: 'Urban Threads', industry: 'E-Commerce',
      location: 'Mumbai, India', ownerName: 'Rahul Kapoor',
      description: 'Sustainable fashion D2C brand.', teamSize: '11-50',
      projectsPosted: 7, hiresCount: 12, logoUrl: avatar(62),
    ),
    Company(
      id: 'co3', name: 'Helpline AI', industry: 'SaaS',
      location: 'Remote', ownerName: 'Divya Menon',
      description: 'AI customer support automation.', teamSize: '11-50',
      projectsPosted: 11, hiresCount: 20, logoUrl: avatar(64),
    ),
  ];

  // ---- Startups ----
  static final List<Startup> startups = [
    Startup(
      id: 's1', name: 'FarmLink', tagline: 'Connecting farmers directly to buyers',
      industry: 'AgriTech', stage: 'Early Revenue', founderName: 'Ishaan Verma',
      fundingRequired: 20000000, equityOffered: 12, location: 'Pune, India',
      problem: 'Farmers lose 30% margin to middlemen.',
      solution: 'A marketplace + logistics network for direct farm-to-business trade.',
      businessModel: 'B2B Marketplace', revenueModel: 'Commission + SaaS',
      marketSize: '\u20B94.2L Cr', valuation: 160000000, fundingRaised: 6000000,
      views: 3200, investorInterests: 24, founderAvatar: avatar(70),
      tags: const ['AgriTech', 'Marketplace', 'B2B'],
    ),
    Startup(
      id: 's2', name: 'MediSync', tagline: 'AI triage for clinics',
      industry: 'HealthTech', stage: 'MVP', founderName: 'Dr. Neha Gupta',
      fundingRequired: 35000000, equityOffered: 15, location: 'Hyderabad, India',
      problem: 'Clinics are overwhelmed and triage is slow.',
      solution: 'AI-driven patient triage and appointment orchestration.',
      businessModel: 'B2B SaaS', revenueModel: 'Subscription',
      marketSize: '\u20B92.8L Cr', valuation: 230000000, fundingRaised: 5000000,
      views: 2600, investorInterests: 31, founderAvatar: avatar(71),
      tags: const ['HealthTech', 'AI', 'SaaS'],
    ),
    Startup(
      id: 's3', name: 'EduSpark', tagline: 'Personalised learning for Bharat',
      industry: 'EdTech', stage: 'Growth', founderName: 'Arjun Nair',
      fundingRequired: 50000000, equityOffered: 10, location: 'Bengaluru, India',
      problem: 'One-size-fits-all education fails most students.',
      solution: 'Adaptive learning paths in regional languages.',
      businessModel: 'B2C + B2B2C', revenueModel: 'Subscription',
      marketSize: '\u20B96L Cr', valuation: 500000000, fundingRaised: 30000000,
      views: 5400, investorInterests: 48, founderAvatar: avatar(72),
      tags: const ['EdTech', 'AI', 'Regional'],
    ),
    Startup(
      id: 's4', name: 'GreenCharge', tagline: 'EV charging as a service',
      industry: 'CleanTech', stage: 'Early Revenue', founderName: 'Sana Khan',
      fundingRequired: 80000000, equityOffered: 18, location: 'Delhi, India',
      problem: 'EV adoption is blocked by charging anxiety.',
      solution: 'Distributed EV charging network with smart routing.',
      businessModel: 'Infrastructure', revenueModel: 'Usage + Subscription',
      marketSize: '\u20B93.5L Cr', valuation: 400000000, fundingRaised: 25000000,
      views: 4100, investorInterests: 37, founderAvatar: avatar(73),
      tags: const ['CleanTech', 'EV', 'Infra'],
    ),
  ];

  // ---- Investors ----
  static final List<Investor> investors = [
    Investor(
      id: 'i1', name: 'Rajiv Anand', investorType: 'Angel Investor',
      company: 'Anand Ventures', location: 'Mumbai, India',
      minInvestment: 2500000, maxInvestment: 25000000,
      interestedIndustries: const ['FinTech', 'SaaS', 'AI'],
      bio: 'Ex-founder, now backing early-stage founders across India.',
      partnerRole: 'Strategic Partner', dealsCount: 42, portfolioCount: 18, avatarUrl: avatar(80),
    ),
    Investor(
      id: 'i2', name: 'Kavya Desai', investorType: 'VC Partner',
      company: 'Lighthouse Capital', location: 'Bengaluru, India',
      minInvestment: 50000000, maxInvestment: 300000000,
      interestedIndustries: const ['HealthTech', 'EdTech', 'CleanTech'],
      bio: 'Partner focused on impact-driven scalable startups.',
      partnerRole: 'Sleeping Partner', dealsCount: 67, portfolioCount: 29, avatarUrl: avatar(81),
    ),
    Investor(
      id: 'i3', name: 'Suresh Pillai', investorType: 'Family Office',
      company: 'Pillai Holdings', location: 'Chennai, India',
      minInvestment: 10000000, maxInvestment: 100000000,
      interestedIndustries: const ['Manufacturing', 'AgriTech', 'E-Commerce'],
      bio: 'Long-term capital for founders building enduring businesses.',
      partnerRole: 'Working Partner', dealsCount: 23, portfolioCount: 14, avatarUrl: avatar(82),
    ),
  ];

  // ---- Deals ----
  static final List<Deal> deals = [
    Deal(id: 'd1', startupName: 'FarmLink', founderName: 'Ishaan Verma', stage: 'Early Revenue', amount: 20000000, equity: 12, status: EntityStatus.inProgress, updatedAt: _daysAgo(1), startupLogo: avatar(70), hasNda: true, documentsCount: 6),
    Deal(id: 'd2', startupName: 'MediSync', founderName: 'Dr. Neha Gupta', stage: 'MVP', amount: 35000000, equity: 15, status: EntityStatus.underReview, updatedAt: _daysAgo(3), startupLogo: avatar(71), documentsCount: 3),
    Deal(id: 'd3', startupName: 'EduSpark', founderName: 'Arjun Nair', stage: 'Growth', amount: 50000000, equity: 10, status: EntityStatus.pending, updatedAt: _daysAgo(5), startupLogo: avatar(72), hasNda: true, documentsCount: 9),
  ];

  // ---- Portfolio ----
  static final List<PortfolioItem> portfolio = [
    PortfolioItem(id: 'pf1', startupName: 'EduSpark', investedAmount: 15000000, currentValue: 42000000, equity: 6, investedAt: _daysAgo(420), logoUrl: avatar(72)),
    PortfolioItem(id: 'pf2', startupName: 'GreenCharge', investedAmount: 20000000, currentValue: 26000000, equity: 8, investedAt: _daysAgo(200), logoUrl: avatar(73)),
    PortfolioItem(id: 'pf3', startupName: 'FarmLink', investedAmount: 5000000, currentValue: 4200000, equity: 4, investedAt: _daysAgo(120), logoUrl: avatar(70)),
  ];

  // ---- Founders ----
  static final List<Founder> founders = [
    Founder(id: 'fo1', name: 'Ishaan Verma', founderType: 'Solo Founder', location: 'Pune, India', bio: 'Building FarmLink to empower farmers.', skills: const ['Product', 'Ops', 'Sales'], startupName: 'FarmLink', avatarUrl: avatar(70), followers: 820),
    Founder(id: 'fo2', name: 'Dr. Neha Gupta', founderType: 'Technical Founder', location: 'Hyderabad, India', bio: 'Physician-turned-founder in HealthTech.', skills: const ['AI', 'Healthcare', 'Product'], startupName: 'MediSync', avatarUrl: avatar(71), followers: 1130),
  ];

  static final List<InvestorRequest> investorRequests = [
    InvestorRequest(id: 'ir1', investorName: 'Rajiv Anand', amount: 15000000, equity: 8, status: EntityStatus.pending, createdAt: _daysAgo(1), investorAvatar: avatar(80), message: 'Impressed with your traction. Would love to discuss a seed round.'),
    InvestorRequest(id: 'ir2', investorName: 'Kavya Desai', amount: 40000000, equity: 12, status: EntityStatus.underReview, createdAt: _daysAgo(4), investorAvatar: avatar(81), message: 'Interested in leading your next round.'),
  ];

  // ---- Conversations & messages ----
  static final List<Conversation> conversations = [
    Conversation(id: 'cv1', name: 'Priya Nair', lastMessage: 'Sure, I can start Monday!', lastMessageAt: DateTime.now().subtract(const Duration(minutes: 4)), avatarUrl: avatar(5), unreadCount: 2, isOnline: true, isPinned: true, role: 'Freelancer'),
    Conversation(id: 'cv2', name: 'PayNova Technologies', lastMessage: 'Please share the revised proposal.', lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)), avatarUrl: avatar(60), unreadCount: 0, role: 'Client'),
    Conversation(id: 'cv3', name: 'Rajiv Anand', lastMessage: 'Let\'s schedule the deal room call.', lastMessageAt: DateTime.now().subtract(const Duration(hours: 5)), avatarUrl: avatar(80), unreadCount: 1, isOnline: true, role: 'Investor'),
    Conversation(id: 'cv4', name: 'Rohan Mehta', lastMessage: 'Uploaded the final designs 🎨', lastMessageAt: DateTime.now().subtract(const Duration(days: 1)), avatarUrl: avatar(11), isMuted: true, role: 'Freelancer'),
  ];

  static List<ChatMessage> messagesFor(String conversationId) => [
        ChatMessage(id: 'm1', conversationId: conversationId, senderId: 'them', text: 'Hi! Thanks for reaching out.', sentAt: DateTime.now().subtract(const Duration(minutes: 30)), status: MessageStatus.seen),
        ChatMessage(id: 'm2', conversationId: conversationId, senderId: 'me', text: 'Hello! I reviewed your profile — great work.', sentAt: DateTime.now().subtract(const Duration(minutes: 26)), isMine: true, status: MessageStatus.seen),
        ChatMessage(id: 'm3', conversationId: conversationId, senderId: 'them', text: 'Would you be available for a quick call this week?', sentAt: DateTime.now().subtract(const Duration(minutes: 20)), status: MessageStatus.seen),
        ChatMessage(id: 'm4', conversationId: conversationId, senderId: 'me', text: 'Absolutely. How about Thursday 4pm?', sentAt: DateTime.now().subtract(const Duration(minutes: 8)), isMine: true, status: MessageStatus.delivered),
        ChatMessage(id: 'm5', conversationId: conversationId, senderId: 'them', text: 'Sure, I can start Monday!', sentAt: DateTime.now().subtract(const Duration(minutes: 4)), status: MessageStatus.sent),
      ];

  // ---- Meetings ----
  static final List<Meeting> meetings = [
    Meeting(id: 'mt1', title: 'Project Kickoff — Fintech App', withName: 'PayNova Technologies', startTime: _hoursAhead(20), durationMinutes: 45, status: EntityStatus.active, withAvatar: avatar(60), agenda: 'Scope, milestones and timeline.'),
    Meeting(id: 'mt2', title: 'Deal Room Call', withName: 'Rajiv Anand', startTime: _hoursAhead(52), durationMinutes: 60, status: EntityStatus.active, withAvatar: avatar(80), agenda: 'Discuss seed terms and cap table.'),
    Meeting(id: 'mt3', title: 'Design Review', withName: 'Rohan Mehta', startTime: DateTime.now().subtract(const Duration(days: 2)), durationMinutes: 30, status: EntityStatus.completed, withAvatar: avatar(11)),
  ];

  // ---- Wallet ----
  static const WalletSummary walletSummary =
      WalletSummary(available: 184500, pending: 42000, lifetime: 2340000, escrow: 120000);

  static final List<WalletTransaction> transactions = [
    WalletTransaction(id: 't1', title: 'Milestone payment — ScaleWorks', amount: 100000, type: TransactionType.credit, date: _daysAgo(2), reference: 'INV-2043'),
    WalletTransaction(id: 't2', title: 'Withdrawal to HDFC ****4321', amount: 80000, type: TransactionType.withdrawal, date: _daysAgo(5), reference: 'WD-1180'),
    WalletTransaction(id: 't3', title: 'Escrow funded — Fintech App', amount: 120000, type: TransactionType.escrow, date: _daysAgo(6), reference: 'ESC-9921'),
    WalletTransaction(id: 't4', title: 'Platform fee', amount: 5000, type: TransactionType.debit, date: _daysAgo(6), reference: 'FEE-3321'),
    WalletTransaction(id: 't5', title: 'Refund — cancelled task', amount: 15000, type: TransactionType.refund, date: _daysAgo(9), reference: 'RF-2201'),
  ];

  static final List<Invoice> invoices = [
    Invoice(id: 'inv1', number: 'INV-2043', party: 'ScaleWorks', amount: 100000, issuedAt: _daysAgo(2), status: 'Paid'),
    Invoice(id: 'inv2', number: 'INV-2044', party: 'Glow Naturals', amount: 95000, issuedAt: _daysAgo(30), status: 'Paid'),
    Invoice(id: 'inv3', number: 'INV-2045', party: 'PayNova Technologies', amount: 190000, issuedAt: _daysAgo(1), status: 'Pending'),
  ];

  // ---- Subscriptions ----
  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(id: 'free', name: 'Starter', priceMonthly: 0, priceYearly: 0, tagline: 'Get started for free', features: ['Up to 5 proposals / month', 'Basic profile', 'Community support']),
    SubscriptionPlan(id: 'pro', name: 'Professional', priceMonthly: 999, priceYearly: 9990, isPopular: true, tagline: 'For growing professionals', features: ['Unlimited proposals', 'Verified badge', 'Priority in search', 'Analytics dashboard', 'Priority support']),
    SubscriptionPlan(id: 'business', name: 'Business', priceMonthly: 2999, priceYearly: 29990, tagline: 'For teams & enterprises', features: ['Everything in Pro', 'Team seats', 'Dedicated manager', 'Custom contracts', 'API access']),
  ];

  // ---- Notifications ----
  static final List<AppNotification> notifications = [
    AppNotification(id: 'n1', title: 'New proposal received', body: 'Priya Nair applied to "Fintech Mobile App".', category: NotificationCategory.project, createdAt: DateTime.now().subtract(const Duration(minutes: 12))),
    AppNotification(id: 'n2', title: 'Payment received', body: '\u20B91,00,000 credited from ScaleWorks.', category: NotificationCategory.payment, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    AppNotification(id: 'n3', title: 'Meeting reminder', body: 'Deal Room Call with Rajiv Anand in 2 hours.', category: NotificationCategory.meeting, createdAt: DateTime.now().subtract(const Duration(hours: 5)), isRead: true),
    AppNotification(id: 'n4', title: 'New follower', body: 'Kavya Desai started following you.', category: NotificationCategory.follower, createdAt: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
    AppNotification(id: 'n5', title: 'New 5-star review', body: 'Glow Naturals left you a review.', category: NotificationCategory.review, createdAt: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
    AppNotification(id: 'n6', title: 'Security alert', body: 'New login from Chrome on macOS.', category: NotificationCategory.security, createdAt: DateTime.now().subtract(const Duration(days: 3)), isRead: true),
  ];

  // ---- Reviews ----
  static final List<Review> reviews = [
    Review(id: 'r1', authorName: 'Glow Naturals', rating: 5, comment: 'Exceptional work and communication. Delivered ahead of schedule!', createdAt: _daysAgo(28), authorAvatar: avatar(65), context: 'Brand Identity & Logo Design'),
    Review(id: 'r2', authorName: 'ScaleWorks', rating: 4.5, comment: 'Very skilled and reliable. Highly recommended.', createdAt: _daysAgo(15), authorAvatar: avatar(66), context: 'DevOps: Migrate to Kubernetes'),
    Review(id: 'r3', authorName: 'CloudDesk', rating: 5, comment: 'Great results on SEO — traffic up 40%.', createdAt: _daysAgo(40), authorAvatar: avatar(67), context: 'SEO Retainer'),
  ];

  static final List<PortfolioEntry> portfolioEntries = [
    PortfolioEntry(id: 'pe1', title: 'PayNova Wallet App', category: 'Mobile', description: 'Fintech app with UPI + KYC.', link: 'https://paynova.example'),
    PortfolioEntry(id: 'pe2', title: 'Urban Threads Store', category: 'Web', description: 'Conversion-focused storefront.'),
    PortfolioEntry(id: 'pe3', title: 'Glow Naturals Brand', category: 'Design', description: 'Full brand identity system.'),
  ];

  // ---- Services ----
  static final List<ServiceItem> services = [
    ServiceItem(id: 'sv1', name: 'Flutter App MVP in 4 Weeks', category: 'Mobile Development', description: 'A production-ready cross-platform MVP with auth, payments and a clean dashboard. Includes CI setup and store submission.', priceFrom: 180000, deliveryDays: 28, rating: 4.9, ordersCount: 42, providerName: 'Priya Nair', providerAvatar: avatar(5), tags: const ['Flutter', 'MVP', 'Payments'], deliverables: const ['Source code', 'CI/CD pipeline', 'Store submission', '30-day support']),
    ServiceItem(id: 'sv2', name: 'Conversion-Focused Landing Page', category: 'Design', description: 'High-converting responsive landing page with copywriting and analytics.', priceFrom: 45000, deliveryDays: 7, rating: 4.8, ordersCount: 88, providerName: 'Rohan Mehta', providerAvatar: avatar(11), tags: const ['Figma', 'Webflow', 'CRO'], deliverables: const ['Figma file', 'Responsive build', 'Analytics setup']),
    ServiceItem(id: 'sv3', name: 'RAG Chatbot Integration', category: 'AI / ML', description: 'LLM-powered support chatbot with a RAG pipeline and analytics.', priceFrom: 320000, deliveryDays: 30, rating: 5.0, ordersCount: 17, providerName: 'Karan Singh', providerAvatar: avatar(33), tags: const ['LLMs', 'LangChain', 'Vector DB'], deliverables: const ['Deployed API', 'Admin dashboard', 'Docs']),
    ServiceItem(id: 'sv4', name: 'SEO Growth Retainer', category: 'Marketing', description: 'Monthly SEO, content and reporting to grow organic traffic.', priceFrom: 60000, deliveryDays: 30, rating: 4.7, ordersCount: 53, providerName: 'Ananya Iyer', providerAvatar: avatar(45), tags: const ['SEO', 'Content', 'Analytics'], deliverables: const ['Keyword strategy', '4 articles / mo', 'Monthly report']),
  ];

  // ---- Technologies ----
  static final List<Technology> technologies = [
    Technology(id: 'tech_flutter', name: 'Flutter', category: 'Mobile', description: 'Google\'s UI toolkit for building natively compiled apps for mobile, web and desktop from a single codebase.', popularity: 95, projectsCount: 320, freelancersCount: 210, relatedSkills: const ['Dart', 'BLoC', 'Firebase', 'Riverpod'], resources: const ['flutter.dev', 'Flutter cookbook', 'pub.dev packages']),
    Technology(id: 'tech_react', name: 'React', category: 'Web', description: 'A JavaScript library for building user interfaces with a component model.', popularity: 98, projectsCount: 540, freelancersCount: 380, relatedSkills: const ['Next.js', 'TypeScript', 'Tailwind'], resources: const ['react.dev', 'Next.js docs']),
    Technology(id: 'tech_python', name: 'Python', category: 'AI / ML', description: 'A versatile language powering data science, ML and backend services.', popularity: 97, projectsCount: 610, freelancersCount: 420, relatedSkills: const ['FastAPI', 'Pandas', 'TensorFlow', 'PyTorch'], resources: const ['python.org', 'FastAPI docs']),
    Technology(id: 'tech_aws', name: 'AWS', category: 'DevOps', description: 'Cloud infrastructure platform for compute, storage and managed services.', popularity: 92, projectsCount: 280, freelancersCount: 160, relatedSkills: const ['Kubernetes', 'Terraform', 'Docker'], resources: const ['aws.amazon.com', 'Well-Architected']),
  ];

  // ---- Categories ----
  static final List<CategoryItem> categories = [
    CategoryItem(id: 'cat_mobile', name: 'Mobile Development', description: 'iOS, Android and cross-platform app development for startups and enterprises.', projectsCount: 128, freelancersCount: 210, avgBudget: 320000, subcategories: const ['iOS', 'Android', 'Flutter', 'React Native'], trendingSkills: const ['Flutter', 'Swift', 'Kotlin', 'BLoC']),
    CategoryItem(id: 'cat_web', name: 'Web Development', description: 'Modern web apps, storefronts and dashboards.', projectsCount: 214, freelancersCount: 380, avgBudget: 260000, subcategories: const ['Frontend', 'Backend', 'Full-Stack', 'E-Commerce'], trendingSkills: const ['React', 'Next.js', 'Node.js', 'Tailwind']),
    CategoryItem(id: 'cat_ai', name: 'AI / ML', description: 'Machine learning, LLMs and data science solutions.', projectsCount: 96, freelancersCount: 140, avgBudget: 520000, subcategories: const ['LLMs', 'Computer Vision', 'MLOps', 'Data Science'], trendingSkills: const ['Python', 'LangChain', 'PyTorch', 'RAG']),
    CategoryItem(id: 'cat_design', name: 'Design', description: 'Product design, branding and design systems.', projectsCount: 152, freelancersCount: 260, avgBudget: 120000, subcategories: const ['UI/UX', 'Branding', 'Motion', 'Illustration'], trendingSkills: const ['Figma', 'Design Systems', 'Prototyping']),
  ];

  // ---- Certificates ----
  static final List<Certificate> certificates = [
    Certificate(id: 'cert1', title: 'Google Associate Android Developer', issuer: 'Google', issuedAt: _daysAgo(300), credentialId: 'GAAD-2024-88213', url: 'https://credential.example/gaad', skills: const ['Android', 'Kotlin']),
    Certificate(id: 'cert2', title: 'AWS Certified Solutions Architect', issuer: 'Amazon Web Services', issuedAt: _daysAgo(120), credentialId: 'AWS-SAA-42019', url: 'https://credential.example/aws', skills: const ['AWS', 'Cloud', 'DevOps'], expiresAt: DateTime.now().add(const Duration(days: 900))),
    Certificate(id: 'cert3', title: 'Flutter Advanced Bootcamp', issuer: 'Go Experts Academy', issuedAt: _daysAgo(60), credentialId: 'GEA-FL-5521', skills: const ['Flutter', 'BLoC', 'Testing']),
  ];

  // ---- Investment opportunities ----
  static final List<InvestmentOpportunity> opportunities = [
    InvestmentOpportunity(id: 'op1', startupName: 'FarmLink', industry: 'AgriTech', stage: 'Early Revenue', amountSought: 20000000, equityOffered: 12, minTicket: 2500000, valuation: 160000000, summary: 'Direct farm-to-business marketplace with an integrated logistics network.', highlights: const ['₹6Cr ARR run-rate', '3,200 active farmers', '28% MoM growth'], founderName: 'Ishaan Verma', logoUrl: avatar(70), deadline: DateTime.now().add(const Duration(days: 30)), raisedSoFar: 12000000),
    InvestmentOpportunity(id: 'op2', startupName: 'MediSync', industry: 'HealthTech', stage: 'MVP', amountSought: 35000000, equityOffered: 15, minTicket: 5000000, valuation: 230000000, summary: 'AI-driven patient triage and appointment orchestration for clinics.', highlights: const ['12 pilot clinics', 'HIPAA-ready', 'Ex-Apollo founding team'], founderName: 'Dr. Neha Gupta', logoUrl: avatar(71), deadline: DateTime.now().add(const Duration(days: 45)), raisedSoFar: 9000000),
    InvestmentOpportunity(id: 'op3', startupName: 'EduSpark', industry: 'EdTech', stage: 'Growth', amountSought: 50000000, equityOffered: 10, minTicket: 10000000, valuation: 500000000, summary: 'Adaptive learning paths in regional languages for Bharat.', highlights: const ['540K MAU', '₹30Cr raised to date', '68% retention'], founderName: 'Arjun Nair', logoUrl: avatar(72), deadline: DateTime.now().add(const Duration(days: 21)), raisedSoFar: 38000000),
  ];

  // ---- Business plans & pitch decks (keyed by startup id) ----
  static final Map<String, BusinessPlan> businessPlans = {
    's1': BusinessPlan(id: 'bp_s1', startupName: 'FarmLink', updatedAt: _daysAgo(6), summary: 'A comprehensive plan to scale direct farm-to-business trade across India.', sections: const [
      PlanSection(title: 'Executive Summary', content: 'FarmLink removes middlemen from agricultural trade, returning up to 30% margin to farmers via a marketplace and logistics network.'),
      PlanSection(title: 'Market Opportunity', content: 'India\'s agri-trade market is ₹4.2L Cr, largely offline and fragmented. FarmLink digitises procurement for businesses.'),
      PlanSection(title: 'Strategy', content: 'Land-and-expand across agri clusters, starting in Maharashtra, with an asset-light logistics partner network.'),
      PlanSection(title: 'Revenue Model', content: 'Transaction commission (3-5%) plus a SaaS subscription for enterprise buyers.'),
      PlanSection(title: 'Operations', content: 'Regional collection centres, quality grading and cold-chain partners.'),
      PlanSection(title: 'Financials', content: 'Projected ₹40Cr GMV in FY26 at 8% take rate, breakeven in 18 months.'),
      PlanSection(title: 'Roadmap', content: 'Q1: 3 new clusters · Q2: enterprise SaaS launch · Q3: cold-chain expansion.'),
    ]),
  };

  static final Map<String, PitchDeck> pitchDecks = {
    's1': PitchDeck(id: 'pd_s1', startupName: 'FarmLink', updatedAt: _daysAgo(6), views: 312, slides: const [
      DeckSlide(title: 'FarmLink', subtitle: 'Connecting farmers directly to buyers'),
      DeckSlide(title: 'The Problem', subtitle: 'Farmers lose 30% margin to middlemen'),
      DeckSlide(title: 'The Solution', subtitle: 'A marketplace + logistics network'),
      DeckSlide(title: 'Market', subtitle: '₹4.2L Cr agri-trade opportunity'),
      DeckSlide(title: 'Traction', subtitle: '3,200 farmers · ₹6Cr run-rate'),
      DeckSlide(title: 'Business Model', subtitle: 'Commission + SaaS'),
      DeckSlide(title: 'Team', subtitle: 'Ex-agri operators & engineers'),
      DeckSlide(title: 'The Ask', subtitle: '₹2Cr for 12% equity'),
    ]),
  };

  // ---- Invitations ----
  static final List<AppInvitation> invitationsSent = [
    AppInvitation(id: 'invs1', name: 'Priya Nair', role: 'Freelancer', context: 'Fintech Mobile App', type: 'Invite Freelancer', status: EntityStatus.pending, createdAt: _daysAgo(1), avatarUrl: avatar(5)),
    AppInvitation(id: 'invs2', name: 'Karan Singh', role: 'Freelancer', context: 'AI Chatbot', type: 'Invite Freelancer', status: EntityStatus.accepted, createdAt: _daysAgo(4), avatarUrl: avatar(33)),
    AppInvitation(id: 'invs3', name: 'Rajiv Anand', role: 'Investor', context: 'Seed Round', type: 'Invite Investor', status: EntityStatus.expired, createdAt: _daysAgo(20), avatarUrl: avatar(80)),
  ];

  static final List<AppInvitation> invitationsReceived = [
    AppInvitation(id: 'invr1', name: 'PayNova Technologies', role: 'Client', context: 'Fintech Mobile App', type: 'Project Invite', status: EntityStatus.pending, createdAt: _hoursAgo(6), avatarUrl: avatar(60)),
    AppInvitation(id: 'invr2', name: 'Lighthouse Capital', role: 'Investor', context: 'Mentorship', type: 'Mentor Invite', status: EntityStatus.rejected, createdAt: _daysAgo(8), avatarUrl: avatar(81)),
  ];

  static DateTime _hoursAgo(int h) => DateTime.now().subtract(Duration(hours: h));
}

/// A sent or received invitation (freelancer/investor/founder/partner/mentor).
class AppInvitation {
  const AppInvitation({
    required this.id,
    required this.name,
    required this.role,
    required this.context,
    required this.type,
    required this.status,
    required this.createdAt,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String role;
  final String context;
  final String type;
  final EntityStatus status;
  final DateTime createdAt;
  final String? avatarUrl;
}
