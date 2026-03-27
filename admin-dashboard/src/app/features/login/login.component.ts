import { Component, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="login-page">
      <div class="login-card">
        <div class="logo">
          <span class="logo-icon">GP</span>
          <h1>GymPass Admin</h1>
          <p>One Subscription, Play Anywhere</p>
        </div>

        @if (!otpSent()) {
          <div class="form-group">
            <label>Phone Number</label>
            <input type="tel" [(ngModel)]="phone" placeholder="+962791234567"
                   (keyup.enter)="sendOtp()" [disabled]="loading()">
          </div>
          <button class="btn-primary" (click)="sendOtp()" [disabled]="loading()">
            {{ loading() ? 'Sending...' : 'Send OTP' }}
          </button>
        } @else {
          <div class="form-group">
            <label>Enter OTP Code</label>
            <input type="text" [(ngModel)]="code" placeholder="123456" maxlength="6"
                   (keyup.enter)="verifyOtp()" [disabled]="loading()">
            <small class="hint">Debug mode — use 123456</small>
          </div>
          <button class="btn-primary" (click)="verifyOtp()" [disabled]="loading()">
            {{ loading() ? 'Verifying...' : 'Login' }}
          </button>
          <button class="btn-secondary" (click)="otpSent.set(false)">← Back</button>
        }

        @if (error()) {
          <div class="error">{{ error() }}</div>
        }

        @if (debugOtp()) {
          <div class="debug">Debug OTP: {{ debugOtp() }}</div>
        }
      </div>
    </div>
  `,
  styles: [`
    .login-page {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #000;
    }
    .login-card {
      background: #111;
      border: 1px solid #222;
      border-radius: 16px;
      padding: 40px;
      width: 100%;
      max-width: 400px;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .logo {
      text-align: center;
      margin-bottom: 8px;
    }
    .logo-icon {
      background: #00FF88;
      color: #000;
      font-weight: 800;
      font-size: 28px;
      width: 64px;
      height: 64px;
      border-radius: 16px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 12px;
    }
    h1 { color: #fff; font-size: 24px; margin: 0; }
    .logo p { color: #888; font-size: 14px; margin-top: 4px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    label { color: #888; font-size: 13px; font-weight: 600; }
    input {
      background: #0a0a0a;
      border: 1px solid #333;
      border-radius: 8px;
      padding: 12px;
      color: #fff;
      font-size: 16px;
      outline: none;
    }
    input:focus { border-color: #00FF88; }
    .hint { color: #00FF88; font-size: 12px; }
    .btn-primary {
      background: #00FF88;
      color: #000;
      border: none;
      border-radius: 8px;
      padding: 12px;
      font-size: 16px;
      font-weight: 700;
      cursor: pointer;
      transition: opacity 0.2s;
    }
    .btn-primary:hover { opacity: 0.9; }
    .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
    .btn-secondary {
      background: none;
      border: 1px solid #333;
      border-radius: 8px;
      padding: 10px;
      color: #888;
      cursor: pointer;
      font-size: 14px;
    }
    .btn-secondary:hover { border-color: #666; color: #fff; }
    .error {
      background: rgba(255,59,48,0.1);
      border: 1px solid rgba(255,59,48,0.3);
      color: #FF3B30;
      padding: 10px;
      border-radius: 8px;
      font-size: 13px;
    }
    .debug {
      background: rgba(0,255,136,0.1);
      border: 1px solid rgba(0,255,136,0.3);
      color: #00FF88;
      padding: 10px;
      border-radius: 8px;
      font-size: 13px;
      text-align: center;
    }
  `]
})
export class LoginComponent {
  phone = '';
  code = '';
  otpSent = signal(false);
  loading = signal(false);
  error = signal('');
  debugOtp = signal('');

  private auth = inject(AuthService);
  private router = inject(Router);

  sendOtp(): void {
    if (!this.phone) return;
    this.loading.set(true);
    this.error.set('');
    this.auth.sendOtp(this.phone).subscribe({
      next: (res) => {
        this.otpSent.set(true);
        this.debugOtp.set(res.debug_otp ?? '');
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(err.error?.detail ?? 'Failed to send OTP');
        this.loading.set(false);
      },
    });
  }

  verifyOtp(): void {
    if (!this.code) return;
    this.loading.set(true);
    this.error.set('');
    this.auth.verifyOtp(this.phone, this.code).subscribe({
      next: (res) => {
        const ok = this.auth.handleLogin(res);
        if (ok) {
          this.router.navigate(['/dashboard']);
        } else {
          this.error.set('Admin access required. Your role: ' + res.user.role);
        }
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(err.error?.detail ?? 'Invalid OTP');
        this.loading.set(false);
      },
    });
  }
}
