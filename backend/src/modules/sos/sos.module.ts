import { Module } from '@nestjs/common';
import { SosService } from './sos.service';
import { SosController } from './sos.controller';
import { PrismaService } from '../../database/prisma.service';

@Module({
  controllers: [SosController],
  providers: [SosService, PrismaService],
})
export class SosModule {}
