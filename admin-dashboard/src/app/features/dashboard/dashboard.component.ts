import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AdminService } from '../../core/services/admin.service';
import { AuthService } from '../../core/services/auth.service';
import { StatCardComponent } from '../../shared/components/stat-card/stat-card.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { DashboardStats } from '../../core/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, StatCardComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <div>
          <h1>Dashboard</h1>
          <p>Welcome back, {{ auth.user()?.full_name }}</p>
        </div>
      </div>

      @if (loading()) {
        <app-loading-spinner message="Loading stats..." />
      } @else if (stats()) {
        <div class="stats-grid">
          <app-stat-card icon="👥" label="Total Users" [value]="stats()!.users" color="var(--accent)" />
          <app-stat-card icon="🏋️" label="Partner Gyms" [value]="stats()!.gyms" color="var(--info)" />
          <app-stat-card icon="💳" label="Active Subscriptions" [value]="stats()!.active_subscriptions" color="var(--warning)" />
          <app-stat-card icon="⏳" label="Pending Subscriptions" [value]="stats()!.pending_subscriptions" color="#FF9500" />
          <app-stat-card icon="✅" label="Total Check-ins" [value]="stats()!.total_checkins" color="#AF52DE" />
          <app-stat-card icon="💰" label="Total Revenue (JD)" [value]="stats()!.total_revenue" color="var(--accent)" />
        </div>

        <div class="quick-actions">
          <h2>Quick Actions</h2>
          <div class="actions-grid">
            <a routerLink="/users" class="action-card">
              <span>👥</span>
              <span>Manage Users</span>
            </a>
            <a routerLink="/gyms" class="action-card">
              <span>🏋️</span>
              <span>Manage Gyms</span>
            </a>
            <a routerLink="/subscriptions" class="action-card">
              <span>💳</span>
              <span>Subscriptions</span>
            </a>
            <a routerLink="/settlements" class="action-card">
              <span>🏦</span>
              <span>Settlements</span>
            </a>
            <a routerLink="/settings" class="action-card">
              <span>🔗</span>
              <span>App Links</span>
            </a>
          </div>
        </div>
      }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { margin-bottom: 32px; }
    .page-header h1 { color: var(--text-primary); font-size: 28px; margin: 0; }
    .page-header p { color: var(--text-muted); margin-top: 4px; }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 16px;
      margin-bottom: 40px;
    }
    .quick-actions h2 { color: var(--text-primary); font-size: 20px; margin-bottom: 16px; }
    .actions-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 12px;
    }
    .action-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 20px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
      text-decoration: none;
      color: #ccc;
      font-size: 14px;
      transition: all 0.2s;
    }
    .action-card:hover {
      border-color: var(--accent);
      color: var(--accent);
      transform: translateY(-2px);
    }
    .action-card span:first-child { font-size: 28px; }
  `]
})
export class DashboardComponent implements OnInit {
  stats = signal<DashboardStats | null>(null);
  loading = signal(true);

  auth = inject(AuthService);
  private adminService = inject(AdminService);

  ngOnInit(): void {
    this.adminService.getStats().subscribe({
      next: (data) => { this.stats.set(data); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }
}
