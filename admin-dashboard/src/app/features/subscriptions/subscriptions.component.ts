import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Subscription } from '../../core/models';

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
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" /> }
    </div>

    @if (showModal()) {
      <div class="modal-backdrop" (click)="showModal.set(false)">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>Subscription Details</h2>
            <button class="close-btn" (click)="showModal.set(false)">✕</button>
          </div>
          <div class="modal-body">
            @if (selected()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selected()!.id }}</span></div>
                <div class="detail-item"><span class="label">User ID</span><span class="value id-val">{{ selected()!.user_id }}</span></div>
                <div class="detail-item"><span class="label">Plan ID</span><span class="value id-val">{{ selected()!.plan_id }}</span></div>
                <div class="detail-item"><span class="label">Status</span><span class="value badge" [style.color]="statusColor(selected()!.status)">{{ selected()!.status }}</span></div>
                <div class="detail-item"><span class="label">Price Paid</span><span class="value">{{ selected()!.price_paid }} JD</span></div>
                <div class="detail-item"><span class="label">Daily Rate</span><span class="value">{{ selected()!.daily_rate }} JD</span></div>
                <div class="detail-item"><span class="label">Visits Used</span><span class="value">{{ selected()!.visits_used }} / {{ selected()!.max_visits }}</span></div>
                <div class="detail-item"><span class="label">Visits Remaining</span><span class="value">{{ selected()!.visits_remaining }}</span></div>
                <div class="detail-item"><span class="label">Wallet Balance</span><span class="value">{{ selected()!.wallet_balance }} JD</span></div>
                <div class="detail-item"><span class="label">Auto Renew</span><span class="value">{{ selected()!.auto_renew ? '✅ Yes' : '❌ No' }}</span></div>
                <div class="detail-item"><span class="label">Started</span><span class="value">{{ selected()!.started_at | date:'medium' }}</span></div>
                <div class="detail-item"><span class="label">Expires</span><span class="value">{{ selected()!.expires_at | date:'medium' }}</span></div>
                <div class="detail-item"><span class="label">Created</span><span class="value">{{ selected()!.created_at | date:'medium' }}</span></div>
              </div>
              @if (selected()!.status === 'pending') {
                <div class="modal-actions">
                  <button class="btn-activate" (click)="activateSelected()">✅ Activate</button>
                </div>
              }
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; }
    .filter-select { background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px; color: #fff; font-size: 14px; outline: none; }
    .btn-action { background: #00FF88; color: #000; border: none; border-radius: 8px; padding: 8px 16px; font-weight: 600; cursor: pointer; font-size: 13px; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: #111; border: 1px solid #222; border-radius: 16px; width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid #222; }
    .modal-header h2 { color: #fff; font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: #888; font-size: 20px; cursor: pointer; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .label { color: #888; font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: #fff; font-size: 14px; } .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
    .modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
    .btn-activate { background: #00FF88; color: #000; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 700; cursor: pointer; font-size: 14px; }
  `]
})
export class SubscriptionsComponent implements OnInit {
  loading = signal(true);
  subs = signal<Subscription[]>([]);
  tableData = signal<Record<string, unknown>[]>([]);
  statusFilter = '';
  showModal = signal(false);
  selected = signal<Subscription | null>(null);

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
      next: (data: Subscription[]) => { this.subs.set(data); this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const sub = this.subs().find(s => s.id === id);
    if (!sub) return;
    if (event.action === 'view' || event.action === 'edit') { this.selected.set(sub); this.showModal.set(true); }
    if (event.action === 'delete' && sub.status === 'pending') {
      if (confirm('Activate this subscription?')) this.adminService.activateSubscription(id).subscribe(() => this.load());
    }
  }

  activateSelected(): void {
    const s = this.selected();
    if (s) this.adminService.activateSubscription(s.id).subscribe(() => { this.showModal.set(false); this.load(); });
  }

  expireAll(): void {
    if (confirm('Expire all due subscriptions?')) this.adminService.expireSubscriptions().subscribe(() => this.load());
  }

  statusColor(s: string): string { return ({ active: '#00FF88', pending: '#FFD60A', expired: '#FF3B30', cancelled: '#888' } as Record<string, string>)[s] || '#888'; }
}
