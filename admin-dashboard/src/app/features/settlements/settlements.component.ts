import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Settlement } from '../../core/models';

@Component({
  selector: 'app-settlements',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Gym Settlements</h1>
        <div class="filters">
          <select [(ngModel)]="statusFilter" (change)="load()" class="filter-select">
            <option value="">All</option>
            <option value="pending">Pending</option>
            <option value="paid">Paid</option>
          </select>
          <button class="btn-action" (click)="runSettlement()">🔄 Run Settlement</button>
        </div>
      </div>
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" /> }
    </div>

    @if (showModal()) {
      <div class="modal-backdrop" (click)="showModal.set(false)">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>Settlement Details</h2>
            <button class="close-btn" (click)="showModal.set(false)">✕</button>
          </div>
          <div class="modal-body">
            @if (selected()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selected()!.id }}</span></div>
                <div class="detail-item"><span class="label">Gym ID</span><span class="value id-val">{{ selected()!.gym_id }}</span></div>
                <div class="detail-item"><span class="label">Total Visits</span><span class="value">{{ selected()!.total_visits }}</span></div>
                <div class="detail-item"><span class="label">Total Amount</span><span class="value" style="color:var(--accent);font-weight:700">{{ selected()!.total_amount }} JD</span></div>
                <div class="detail-item"><span class="label">Status</span><span class="value badge" [style.color]="selected()!.status === 'paid' ? 'var(--success)' : 'var(--warning)'">{{ selected()!.status }}</span></div>
                <div class="detail-item"><span class="label">Period</span><span class="value">{{ selected()!.period_start }} — {{ selected()!.period_end }}</span></div>
                <div class="detail-item"><span class="label">Paid At</span><span class="value">{{ selected()!.paid_at || '—' }}</span></div>
              </div>
              @if (selected()!.status === 'pending') {
                <div class="modal-actions">
                  <button class="btn-pay" (click)="markPaid()">💰 Mark as Paid</button>
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
    .page-header h1 { color: var(--text-primary); font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; }
    .filter-select { background: var(--bg-card); border: 1px solid var(--border-light); border-radius: 8px; padding: 8px 12px; color: var(--text-primary); font-size: 14px; outline: none; }
    .btn-action { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 8px 16px; font-weight: 600; cursor: pointer; font-size: 13px; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--border); }
    .modal-header h2 { color: var(--text-primary); font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .label { color: var(--text-muted); font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: var(--text-primary); font-size: 14px; } .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
    .modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
    .btn-pay { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 10px 20px; font-weight: 700; cursor: pointer; font-size: 14px; }
  `]
})
export class SettlementsComponent implements OnInit {
  loading = signal(true);
  settlements = signal<Settlement[]>([]);
  tableData = signal<Record<string, unknown>[]>([]);
  statusFilter = '';
  showModal = signal(false);
  selected = signal<Settlement | null>(null);

  columns: TableColumn[] = [
    { key: 'gym_id', label: 'Gym ID' },
    { key: 'total_visits', label: 'Visits' },
    { key: 'total_amount', label: 'Amount (JD)' },
    { key: 'status', label: 'Status', type: 'badge', badgeColors: { pending: 'var(--warning)', paid: 'var(--success)' } },
    { key: 'period_start', label: 'Period Start' },
    { key: 'period_end', label: 'Period End' },
    { key: 'paid_at', label: 'Paid At', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getSettlements(0, 100, this.statusFilter || undefined).subscribe({
      next: (data: Settlement[]) => { this.settlements.set(data); this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  runSettlement(): void {
    if (confirm('Run settlement for the previous month?')) {
      this.adminService.runSettlement().subscribe(() => this.load());
    }
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const item = this.settlements().find(s => s.id === id);
    if (!item) return;
    if (event.action === 'view' || event.action === 'edit') { this.selected.set(item); this.showModal.set(true); }
    if (event.action === 'delete' && item.status === 'pending' && confirm('Mark as paid?')) {
      this.adminService.markSettlementPaid(id).subscribe(() => this.load());
    }
  }

  markPaid(): void {
    const s = this.selected();
    if (s) this.adminService.markSettlementPaid(s.id).subscribe(() => { this.showModal.set(false); this.load(); });
  }
}
