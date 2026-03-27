import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { User } from '../../core/models';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Users</h1>
        <div class="filters">
          <input type="text" [(ngModel)]="search" placeholder="Search phone or name..."
                 (keyup.enter)="loadUsers()" class="search-input">
          <select [(ngModel)]="roleFilter" (change)="loadUsers()" class="filter-select">
            <option value="">All Roles</option>
            <option value="member">Member</option>
            <option value="gym_partner">Gym Partner</option>
            <option value="admin">Admin</option>
          </select>
        </div>
      </div>
      @if (loading()) {
        <app-loading-spinner />
      } @else {
        <app-data-table [columns]="columns" [data]="usersData()" (action)="onAction($event)" />
      }
    </div>
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .page-header h1 { color: #fff; font-size: 24px; margin: 0; }
    .filters { display: flex; gap: 8px; }
    .search-input, .filter-select {
      background: #111; border: 1px solid #333; border-radius: 8px; padding: 8px 12px;
      color: #fff; font-size: 14px; outline: none;
    }
    .search-input:focus, .filter-select:focus { border-color: #00FF88; }
  `]
})
export class UsersComponent implements OnInit {
  loading = signal(true);
  users = signal<User[]>([]);
  search = '';
  roleFilter = '';

  columns: TableColumn[] = [
    { key: 'full_name', label: 'Name' },
    { key: 'phone', label: 'Phone' },
    { key: 'role', label: 'Role', type: 'badge', badgeColors: { member: '#00FF88', gym_partner: '#00D4FF', admin: '#FFD60A', super_admin: '#FF3B30' } },
    { key: 'is_active', label: 'Active', type: 'boolean' },
    { key: 'created_at', label: 'Joined', type: 'date' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  usersData = signal<Record<string, unknown>[]>([]);

  private adminService = inject(AdminService);

  ngOnInit(): void { this.loadUsers(); }

  loadUsers(): void {
    this.loading.set(true);
    this.adminService.getUsers(0, 100, this.roleFilter || undefined, this.search || undefined).subscribe({
      next: (data) => {
        this.users.set(data);
        this.usersData.set(data as unknown as Record<string, unknown>[]);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    if (event.action === 'delete' && confirm('Deactivate this user?')) {
      this.adminService.deleteUser(id).subscribe(() => this.loadUsers());
    }
  }
}
