import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsLatitude, IsLongitude } from 'class-validator';
import { Type } from 'class-transformer';
import { SOSStatus } from '@prisma/client';

export class CreateSosDto {
  @ApiPropertyOptional({ example: 40.7128 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @IsLatitude()
  latitude?: number;

  @ApiPropertyOptional({ example: -74.0060 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @IsLongitude()
  longitude?: number;

  @ApiPropertyOptional({ example: 'Need emergency help!' })
  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateSosStatusDto {
  @ApiProperty({ enum: SOSStatus })
  status: SOSStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  resolvedBy?: string;
}
