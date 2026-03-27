import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-subscriptions',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Subscriptions</h1>
        <div class="filters">
          <select [(ngModel)]="statusFilter" (change)="load()" class="filter-select">
            <option value="">All</option>
            <option value="active">Active</option>
            <option value="pending">Pending</option>
            <option value="expired">Expired</option>
          </select>
          <button class="btn-action" (click)="expireAll()">⏰ Expire Due</button>
        </div>
      </div>
      @if (loading()) {
        <app-loading-spinner />
      } @else {
        <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" />
      }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; }
    .filter-select { background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px; color: #fff; font-size: 14px; outline: none; }
    .btn-action { background: #00FF88; color: #000; border: none; border-radius: 8px; padding: 8px 16px; font-weight: 600; cursor: pointer; font-size: 13px; }
    .btn-action:hover { opacity: 0.9; }
  `]
})
export class SubscriptionsComponent implements OnInit {
  loading = signal(true);
  tableData = signal<Record<string, unknown>[]>([]);
  statusFilter = '';

  columns: TableColumn[] = [
    { key: 'user_id', label: 'User ID' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { active: '#00FF88', pending: '#FFD60A', expired: '#FF3B30', cancelled: '#888' } },
    { key: 'price_paid', label: 'Paid (JD)' },
    { key: 'visits_used', label: 'Visits' },
    { key: 'wallet_balance', label: 'Wallet' },
    { key: 'started_at', label: 'Started', type: 'date' },
    { key: 'expires_at', label: 'Expires', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getSubscriptions(0, 100, this.statusFilter || undefined).subscribe({
      next: (data) => { this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    if (event.action === 'edit') {
      this.adminService.activateSubscription(id).subscribe(() => this.load());
    }
  }

  expireAll(): void {
    this.adminService.expireSubscriptions().subscribe(() => this.load());
  }
}
