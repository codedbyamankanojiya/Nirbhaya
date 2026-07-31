import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsLatitude, IsLongitude, IsBoolean, IsArray, IsEnum, IsInt, Length } from 'class-validator';
import { Type } from 'class-transformer';
import { IncidentStatus } from '@prisma/client';

export class CreateIncidentDto {
  @ApiProperty({ example: 'Harassment incident' })
  @IsString()
  @Length(5, 200)
  title: string;

  @ApiProperty({ example: 'Detailed description of the incident' })
  @IsString()
  @Length(10, 2000)
  description: string;

  @ApiProperty({ example: 'harassment' })
  @IsString()
  category: string;

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

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  isAnonymous?: boolean;

  @ApiPropertyOptional({ type: [String], description: 'Array of media IDs' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  mediaIds?: string[];
}

export class UpdateIncidentDto {
  @ApiPropertyOptional({ example: 'Harassment incident' })
  @IsOptional()
  @IsString()
  @Length(5, 200)
  title?: string;

  @ApiPropertyOptional({ example: 'Detailed description of the incident' })
  @IsOptional()
  @IsString()
  @Length(10, 2000)
  description?: string;

  @ApiPropertyOptional({ example: 'harassment' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ enum: IncidentStatus })
  @IsOptional()
  @IsEnum(IncidentStatus)
  status?: IncidentStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  adminNotes?: string;
}
