import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { environment } from '../../../environments/environment';
import { AuthResponse } from '../models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly TOKEN_KEY = 'gympass_admin_token';
  private readonly REFRESH_KEY = 'gympass_admin_refresh';
  private readonly USER_KEY = 'gympass_admin_user';

  private http = inject(HttpClient);
  private router = inject(Router);

  private _user = signal<AuthResponse['user'] | null>(this.loadUser());
  readonly user = this._user.asReadonly();
  readonly isLoggedIn = computed(() => !!this._user() && !!this.getToken());
  readonly isAdmin = computed(() => {
    const u = this._user();
    return u?.role === 'admin' || u?.role === 'super_admin';
  });

  

  private loadUser(): AuthResponse['user'] | null {
    const raw = localStorage.getItem(this.USER_KEY);
    return raw ? JSON.parse(raw) : null;
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  getRefreshToken(): string | null {
    return localStorage.getItem(this.REFRESH_KEY);
  }

  sendOtp(phone: string) {
    return this.http.post<{ message: string; debug_otp?: string }>(
      `${environment.apiBaseUrl}/auth/send-otp`,
      { phone },
      { headers: { 'X-Country-Code': environment.defaultCountry } }
    );
  }

  verifyOtp(phone: string, code: string) {
    return this.http.post<AuthResponse>(
      `${environment.apiBaseUrl}/auth/verify-otp`,
      { phone, code }
    );
  }

  handleLogin(res: AuthResponse): boolean {
    if (!['admin', 'super_admin'].includes(res.user.role)) {
      return false;
    }
    localStorage.setItem(this.TOKEN_KEY, res.access_token);
    localStorage.setItem(this.REFRESH_KEY, res.refresh_token);
    localStorage.setItem(this.USER_KEY, JSON.stringify(res.user));
    this._user.set(res.user);
    return true;
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_KEY);
    localStorage.removeItem(this.USER_KEY);
    this._user.set(null);
    this.router.navigate(['/login']);
  }

  refreshToken() {
    return this.http.post<{ access_token: string }>(
      `${environment.apiBaseUrl}/auth/refresh`,
      { refresh_token: this.getRefreshToken() }
    );
  }
}
