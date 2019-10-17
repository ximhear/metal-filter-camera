    kernel vec4 kuwahara(sampler image, float r)
        {
           vec2 d = destCoord();
            
           int radius = int(r);
           float n = float((radius + 1) * (radius + 1));
            
           vec3 means[4];
           vec3 stdDevs[4];
            
           for (int i = 0; i < 4; i++)
           {
               means[i] = vec3(0.0);
               stdDevs[i] = vec3(0.0);
           }
            
           for (int x = -radius; x <= radius; x++)
           {
               for (int y = -radius; y <= radius; y++)
               {
                   vec3 color = sample(image, samplerTransform(image, d + vec2(x,y))).rgb; \n
        
                   vec3 colorA = vec3(float(x <= 0 && y <= 0)) * color;
                   means[0] += colorA;
                   stdDevs[0] += colorA * colorA;

                   vec3 colorB = vec3(float(x >= 0 && y <= 0)) * color;
                   means[1] +=  colorB;
                   stdDevs[1] += colorB * colorB;

                   vec3 colorC = vec3(float(x <= 0 && y >= 0)) * color;
                   means[2] += colorC;
                   stdDevs[2] += colorC * colorC;

                   vec3 colorD = vec3(float(x >= 0 && y >= 0)) * color;
                   means[3] += colorD;
                   stdDevs[3] += colorD * colorD;

               }
           }
        
           float minSigma2 = 1e+2;
           vec3 returnColor = vec3(0.0);
        
           for (int j = 0; j < 4; j++)
           {
               means[j] /= n;
               stdDevs[j] = abs(stdDevs[j] / n - means[j] * means[j]); \n

               float sigma2 = stdDevs[j].r + stdDevs[j].g + stdDevs[j].b; \n

               returnColor = (sigma2 < minSigma2) ? means[j] : returnColor;
               minSigma2 = (sigma2 < minSigma2) ? sigma2 : minSigma2;
           }
            
           return vec4(returnColor, 1.0);
        }
