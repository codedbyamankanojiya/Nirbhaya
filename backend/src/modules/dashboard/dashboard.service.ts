import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { IncidentStatus, SOSStatus } from '@prisma/client';

function startOfMonth(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

function endOfMonth(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);
}

function subDays(date: Date, days: number): Date {
  return new Date(date.getTime() - days * 24 * 60 * 60 * 1000);
}

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getDashboardStats() {
    const [
      totalUsers,
      totalSos,
      activeSos,
      totalIncidents,
      pendingIncidents,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.sOS.count(),
      this.prisma.sOS.count({ where: { status: SOSStatus.ACTIVE } }),
      this.prisma.incident.count(),
      this.prisma.incident.count({ where: { status: IncidentStatus.PENDING } }),
    ]);

    return {
      totalUsers,
      totalSos,
      activeSos,
      totalIncidents,
      pendingIncidents,
    };
  }

  async getRecentActivities(limit: number = 10) {
    const recentSos = await this.prisma.sOS.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: { user: { include: { profile: true } } },
    });

    const recentIncidents = await this.prisma.incident.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: { user: { include: { profile: true } } },
    });

    const activities = [
      ...recentSos.map((sos) => ({
        type: 'SOS',
        ...sos,
      })),
      ...recentIncidents.map((incident) => ({
        type: 'INCIDENT',
        ...incident,
      })),
    ].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime()).slice(0, limit);

    return activities;
  }

  async getMonthlyAnalytics() {
    const now = new Date();
    const thisMonthStart = startOfMonth(now);
    const thisMonthEnd = endOfMonth(now);
    const lastMonthStart = startOfMonth(subDays(thisMonthStart, 1));
    const lastMonthEnd = endOfMonth(lastMonthStart);

    const [
      thisMonthSos, lastMonthSos, thisMonthIncidents, lastMonthIncidents] = await Promise.all([
      this.prisma.sOS.count({
        where: { createdAt: { gte: thisMonthStart, lte: thisMonthEnd } },
      }),
      this.prisma.sOS.count({
        where: { createdAt: { gte: lastMonthStart, lte: lastMonthEnd } },
      }),
      this.prisma.incident.count({
        where: { createdAt: { gte: thisMonthStart, lte: thisMonthEnd } },
      }),
      this.prisma.incident.count({
        where: { createdAt: { gte: lastMonthStart, lte: lastMonthEnd } },
      }),
    ]);

    return {
      thisMonth: {
      sos: thisMonthSos,
      incidents: thisMonthIncidents,
    },
    lastMonth: {
      sos: lastMonthSos,
      incidents: lastMonthIncidents,
    },
  };
  }

  async getUserStats(userId: string) {
    const [
      userSosCount, userIncidentsCount, userContactsCount] = await Promise.all([
      this.prisma.sOS.count({ where: { userId } }),
      this.prisma.incident.count({ where: { userId } }),
      this.prisma.emergencyContact.count({ where: { userId } }),
    ]);

    return {
      sosCount: userSosCount,
      incidentsCount: userIncidentsCount,
      contactsCount: userContactsCount,
    };
  }
}
