  
##########################################################################
#Serverless Firebase Development
##########################################################################


##########################################################################
# Task 1: Create a Firestore database
##########################################################################

##########################################################################
# Task 2: Populate the Database
##########################################################################

clone in console shell:
git clone https://github.com/rosera/pet-theory.git


cd ~/pet-theory/lab06/firebase-import-csv/solution
npm install
node index.js netflix_titles_original.csv


##########################################################################
# Task 3: Create a REST API
##########################################################################

npm install

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1

gcloud beta run deploy netflix-dataset-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
  
SERVICE_URL=$(gcloud beta run services describe netflix-dataset-service --platform managed --region us-central1 --format="value(status.url)")

echo $SERVICE_URL

curl -X GET $SERVICE_URL


##########################################################################
# Task 4: Firestore API access
##########################################################################

cd ../solution-02
npm install

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2

gcloud beta run deploy netflix-dataset-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
  
SERVICE_URL=$(gcloud beta run services describe netflix-dataset-service --platform managed --region us-central1 --format="value(status.url)")

echo $SERVICE_URL

curl -X GET $SERVICE_URL/2019


##########################################################################
# Task 5: Deploy the Staging Frontend
##########################################################################

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1

gcloud beta run deploy frontend-staging-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
 
########################################################################## 
# Task 6: Deploy the Production Frontend
##########################################################################

npm install
   
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-production:0.1
   
gcloud beta run deploy frontend-production-service \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-production:0.1 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated