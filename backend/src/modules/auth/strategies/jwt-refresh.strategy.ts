import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Request } from 'express';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(Strategy, 'jwt-refresh') {
  constructor(
    configService: ConfigService,
    private prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get<string>('jwt.refreshSecret') || 'dev-refresh-secret-change-in-env',
      passReqToCallback: true,
    } as any);
  }

  async validate(req: Request, payload: { sub: string; email: string }) {
    const refreshToken = ExtractJwt.fromAuthHeaderAsBearerToken()(req) || '';
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      include: {
        refreshTokens: {
          where: {
            token: refreshToken,
            isRevoked: false,
            expiresAt: { gt: new Date() },
          },
        },
      },
    });

    if (!user || user.refreshTokens.length === 0) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    return { ...user, refreshToken };
  }
}
