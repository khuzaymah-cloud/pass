import { Component, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { environment } from '../../../environments/environment';

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

        <div class="form-group">
          <label>Username</label>
          <input type="text" [(ngModel)]="username" placeholder="Username"
                 (keyup.enter)="login()" [disabled]="loading()" autocomplete="username">
        </div>
        <div class="form-group">
          <label>Password</label>
          <input type="password" [(ngModel)]="password" placeholder="••••••"
                 (keyup.enter)="login()" [disabled]="loading()" autocomplete="current-password">
        </div>
        <button class="btn-primary" (click)="login()" [disabled]="loading()">
          {{ loading() ? 'Logging in...' : 'Login' }}
        </button>

        @if (error()) {
          <div class="error">{{ error() }}</div>
        }
      </div>
    </div>
  `,
  styles: [`
    .login-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: var(--bg-primary); }
    .login-card { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; padding: 40px; width: 100%; max-width: 400px; display: flex; flex-direction: column; gap: 16px; }
    .logo { text-align: center; margin-bottom: 8px; }
    .logo-icon { background: var(--accent); color: var(--bg-primary); font-weight: 800; font-size: 28px; width: 64px; height: 64px; border-radius: 16px; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 12px; }
    h1 { color: var(--text-primary); font-size: 24px; margin: 0; }
    .logo p { color: var(--text-muted); font-size: 14px; margin-top: 4px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    label { color: var(--text-muted); font-size: 13px; font-weight: 600; }
    input { background: var(--bg-input); border: 1px solid var(--border-light); border-radius: 8px; padding: 12px; color: var(--text-primary); font-size: 16px; outline: none; }
    input:focus { border-color: var(--accent); }
    .btn-primary { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 12px; font-size: 16px; font-weight: 700; cursor: pointer; transition: opacity 0.2s; }
    .btn-primary:hover { opacity: 0.9; }
    .btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
    .error { background: var(--error-bg); border: 1px solid var(--error-border); color: var(--error); padding: 10px; border-radius: 8px; font-size: 13px; }
  `]
})
export class LoginComponent {
  username = '';
  password = '';
  loading = signal(false);
  error = signal('');

  private auth = inject(AuthService);
  private router = inject(Router);

  login(): void {
    if (!this.username || !this.password) {
      this.error.set('Please enter username and password');
      return;
    }
    this.loading.set(true);
    this.error.set('');
    if (this.username === environment.adminUsername && this.password === environment.adminPassword) {
      this.auth.handleAdminLogin();
      this.router.navigate(['/dashboard']);
    } else {
      this.error.set('Invalid username or password');
    }
    this.loading.set(false);
  }
}
