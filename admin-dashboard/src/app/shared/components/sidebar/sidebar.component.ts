import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

interface NavItem {
  label: string;
  icon: string;
  route: string;
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <aside class="sidebar" [class.collapsed]="collapsed">
      <div class="sidebar-header">
        <div class="logo">
          <span class="logo-icon">GP</span>
          <span class="logo-text" *ngIf="!collapsed">GymPass Admin</span>
        </div>
        <button class="toggle-btn" (click)="collapsed = !collapsed">
          <span>{{ collapsed ? '→' : '←' }}</span>
        </button>
      </div>

      <nav class="sidebar-nav">
        @for (item of navItems; track item.route) {
          <a [routerLink]="item.route"
             routerLinkActive="active"
             class="nav-item"
             [title]="item.label">
            <span class="nav-icon">{{ item.icon }}</span>
            <span class="nav-label" *ngIf="!collapsed">{{ item.label }}</span>
          </a>
        }
      </nav>

      <div class="sidebar-footer">
        <button class="nav-item logout-btn" (click)="auth.logout()">
          <span class="nav-icon">🚪</span>
          <span class="nav-label" *ngIf="!collapsed">Logout</span>
        </button>
      </div>
    </aside>
  `,
  styles: [`
    .sidebar {
      width: 260px;
      min-height: 100vh;
      background: var(--bg-input);
      border-right: 1px solid var(--bg-elevated);
      display: flex;
      flex-direction: column;
      transition: width 0.3s ease;
      position: fixed;
      top: 0;
      left: 0;
      z-index: 100;
    }
    .sidebar.collapsed { width: 72px; }
    .sidebar-header {
      padding: 20px 16px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-bottom: 1px solid var(--bg-elevated);
    }
    .logo {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .logo-icon {
      background: var(--accent);
      color: var(--bg-primary);
      font-weight: 800;
      font-size: 16px;
      width: 36px;
      height: 36px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .logo-text {
      color: var(--text-primary);
      font-size: 18px;
      font-weight: 700;
      white-space: nowrap;
    }
    .toggle-btn {
      background: none;
      border: none;
      color: #666;
      cursor: pointer;
      font-size: 16px;
      padding: 4px 8px;
      border-radius: 6px;
    }
    .toggle-btn:hover { background: var(--bg-elevated); color: var(--text-primary); }
    .sidebar-nav {
      flex: 1;
      padding: 12px 8px;
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .nav-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 10px 12px;
      border-radius: 8px;
      color: var(--text-muted);
      text-decoration: none;
      font-size: 14px;
      transition: all 0.2s;
      cursor: pointer;
      border: none;
      background: none;
      width: 100%;
      text-align: left;
    }
    .nav-item:hover { background: var(--bg-elevated); color: var(--text-primary); }
    .nav-item.active { background: var(--accent-bg); color: var(--accent); }
    .nav-icon { font-size: 18px; min-width: 24px; text-align: center; }
    .nav-label { white-space: nowrap; }
    .sidebar-footer { padding: 12px 8px; border-top: 1px solid var(--bg-elevated); }
    .logout-btn:hover { background: var(--error-bg); color: var(--error); }
  `]
})
export class SidebarComponent {
  collapsed = false;

  auth = inject(AuthService);

  navItems: NavItem[] = [
    { label: 'Dashboard', icon: '📊', route: '/dashboard' },
    { label: 'Users', icon: '👥', route: '/users' },
    { label: 'Gyms', icon: '🏋️', route: '/gyms' },
    { label: 'Plans', icon: '📋', route: '/plans' },
    { label: 'Subscriptions', icon: '💳', route: '/subscriptions' },
    { label: 'Check-ins', icon: '✅', route: '/checkins' },
    { label: 'Payments', icon: '💰', route: '/payments' },
    { label: 'Settlements', icon: '🏦', route: '/settlements' },
    { label: 'Countries', icon: '🌍', route: '/countries' },
    { label: 'App Links', icon: '🔗', route: '/settings' },
  ];
}
