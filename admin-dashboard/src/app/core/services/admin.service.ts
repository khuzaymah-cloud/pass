import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  DashboardStats, User, Gym, Plan, Subscription,
  Checkin, Payment, Country, Settlement
} from '../models';

@Injectable({ providedIn: 'root' })
export class AdminService {
  private readonly base = `${environment.apiBaseUrl}/admin`;
  private readonly headers = { 'X-Country-Code': environment.defaultCountry };

  private http = inject(HttpClient);

  // Dashboard
  getStats(): Observable<DashboardStats> {
    return this.http.get<DashboardStats>(`${this.base}/stats`, { headers: this.headers });
  }

  // Users
  getUsers(skip = 0, limit = 50, role?: string, search?: string): Observable<User[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (role) params = params.set('role', role);
    if (search) params = params.set('search', search);
    return this.http.get<User[]>(`${this.base}/users`, { params, headers: this.headers });
  }

  getUser(id: string): Observable<User> {
    return this.http.get<User>(`${this.base}/users/${id}`, { headers: this.headers });
  }

  createUser(data: { phone: string; full_name: string; email?: string; role?: string; gender?: string }): Observable<User> {
    return this.http.post<User>(`${this.base}/users`, data, { headers: this.headers });
  }

  updateUser(id: string, data: { role?: string; is_active?: boolean; full_name?: string; email?: string; gender?: string }): Observable<unknown> {
    return this.http.patch(`${this.base}/users/${id}`, data, { headers: this.headers });
  }

  deleteUser(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/users/${id}`, { headers: this.headers });
  }

  // Gyms
  getGyms(skip = 0, limit = 50, tier?: string, is_active?: boolean, search?: string): Observable<Gym[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (tier) params = params.set('tier', tier);
    if (is_active !== undefined) params = params.set('is_active', String(is_active));
    if (search) params = params.set('search', search);
    return this.http.get<Gym[]>(`${this.base}/gyms`, { params, headers: this.headers });
  }

  getGym(id: string): Observable<Gym> {
    return this.http.get<Gym>(`${this.base}/gyms/${id}`, { headers: this.headers });
  }

  createGym(data: Record<string, unknown>): Observable<Gym> {
    return this.http.post<Gym>(`${this.base}/gyms`, data, { headers: this.headers });
  }

  updateGym(id: string, data: Record<string, unknown>): Observable<unknown> {
    return this.http.patch(`${this.base}/gyms/${id}`, data, { headers: this.headers });
  }

  approveGym(id: string): Observable<unknown> {
    return this.http.patch(`${this.base}/gyms/${id}/approve`, null, { headers: this.headers });
  }

  deleteGym(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/gyms/${id}`, { headers: this.headers });
  }

  // Plans
  getPlans(): Observable<Plan[]> {
    return this.http.get<Plan[]>(`${this.base}/plans`, { headers: this.headers });
  }

  createPlan(data: Record<string, unknown>): Observable<Plan> {
    return this.http.post<Plan>(`${this.base}/plans`, data, { headers: this.headers });
  }

  updatePlan(id: string, data: Record<string, unknown>): Observable<unknown> {
    return this.http.patch(`${this.base}/plans/${id}`, data, { headers: this.headers });
  }

  // Subscriptions
  getSubscriptions(skip = 0, limit = 50, status?: string): Observable<Subscription[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (status) params = params.set('status', status);
    return this.http.get<Subscription[]>(`${this.base}/subscriptions`, { params, headers: this.headers });
  }

  activateSubscription(id: string): Observable<unknown> {
    return this.http.post(`${this.base}/subscriptions/${id}/activate`, null, { headers: this.headers });
  }

  expireSubscriptions(): Observable<unknown> {
    return this.http.post(`${this.base}/expire-subscriptions`, null, { headers: this.headers });
  }

  // Checkins
  getCheckins(skip = 0, limit = 50, gymId?: string, userId?: string): Observable<Checkin[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (gymId) params = params.set('gym_id', gymId);
    if (userId) params = params.set('user_id', userId);
    return this.http.get<Checkin[]>(`${this.base}/checkins`, { params, headers: this.headers });
  }

  // Payments
  getPayments(skip = 0, limit = 50, status?: string): Observable<Payment[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (status) params = params.set('status', status);
    return this.http.get<Payment[]>(`${this.base}/payments`, { params, headers: this.headers });
  }

  // Countries
  getCountries(): Observable<Country[]> {
    return this.http.get<Country[]>(`${this.base}/countries`, { headers: this.headers });
  }

  toggleCountry(id: number, is_active: boolean): Observable<unknown> {
    return this.http.patch(`${this.base}/countries/${id}`, null, {
      params: new HttpParams().set('is_active', String(is_active)),
      headers: this.headers,
    });
  }

  // Settlements
  getSettlements(skip = 0, limit = 50, status?: string): Observable<Settlement[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (status) params = params.set('status', status);
    return this.http.get<Settlement[]>(`${this.base}/settlements`, { params, headers: this.headers });
  }

  runSettlement(): Observable<unknown> {
    return this.http.post(`${this.base}/settlements/run`, null, { headers: this.headers });
  }

  markSettlementPaid(id: string): Observable<unknown> {
    return this.http.patch(`${this.base}/settlements/${id}/pay`, null, { headers: this.headers });
  }
}
