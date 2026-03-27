export interface User {
  id: string;
  phone: string;
  email: string | null;
  full_name: string;
  avatar_url: string | null;
  gender: string | null;
  birth_date: string | null;
  role: string;
  country_id: number;
  preferred_language: string;
  theme_preference: string;
  is_active: boolean;
  created_at: string;
}

export interface Gym {
  id: string;
  name_en: string;
  name_ar: string | null;
  description_en: string | null;
  description_ar: string | null;
  tier: string;
  address: string;
  lat: number;
  lng: number;
  phone: string | null;
  logo_url: string | null;
  cover_url: string | null;
  photos: string[];
  opening_hours: Record<string, { open: string; close: string }>;
  amenities: string[];
  categories: string[];
  is_active: boolean;
  is_featured: boolean;
  rating: number;
  total_reviews: number;
  country_id: number;
}

export interface Plan {
  id: string;
  country_id: number;
  tier: string;
  name_en: string;
  name_ar: string;
  price_local: string;
  daily_rate: string;
  max_visits: number;
  validity_days: number;
  gym_tier_access: string;
  features_en: string[];
  features_ar: string[];
  is_active: boolean;
  sort_order: number;
}

export interface Subscription {
  id: string;
  user_id: string;
  plan_id: string;
  country_id: number;
  status: string;
  price_paid: string;
  daily_rate: string;
  max_visits: number;
  validity_days: number;
  visits_used: number;
  visits_remaining: number;
  wallet_balance: string;
  started_at: string | null;
  expires_at: string | null;
  auto_renew: boolean;
  created_at: string;
}

export interface Checkin {
  id: string;
  user_id: string;
  gym_id: string;
  subscription_id: string;
  qr_token: string;
  checked_in_at: string;
  checked_out_at: string | null;
  status: string;
  daily_rate_paid: string;
  plan_tier: string;
}

export interface Payment {
  id: string;
  subscription_id: string;
  user_id: string;
  amount_local: string;
  currency_code: string;
  vat_rate: string;
  vat_amount: string;
  total_charged: string;
  gateway: string;
  gateway_ref: string | null;
  status: string;
  paid_at: string | null;
  created_at: string;
}

export interface Country {
  id: number;
  code: string;
  name_en: string;
  name_ar: string;
  currency_code: string;
  currency_symbol_en: string;
  currency_symbol_ar: string;
  vat_rate: string;
  phone_prefix: string;
  default_lang: string;
  is_active: boolean;
}

export interface Settlement {
  id: string;
  gym_id: string;
  total_visits: number;
  total_amount: string;
  status: string;
  period_start: string;
  period_end: string;
  paid_at: string | null;
}

export interface DashboardStats {
  users: number;
  gyms: number;
  active_subscriptions: number;
  pending_subscriptions: number;
  total_checkins: number;
  total_revenue: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  is_new_user: boolean;
  user: {
    id: string;
    phone: string;
    full_name: string;
    role: string;
    country_id: number;
    preferred_language: string;
  };
}
